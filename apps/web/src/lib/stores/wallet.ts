import NDK, { LnPaymentInfo, NDKUser, NDKZapConfirmation, NDKZapDetails, NutPaymentInfo } from "@nostr-dev-kit/ndk";
import NDKWallet, { NDKCashuWallet } from "@nostr-dev-kit/ndk-wallet";
import { derived, get, writable } from "svelte/store";
import createDebug from "debug";
import { toast } from "svelte-sonner";
import { ndk } from "./ndk";

const d = createDebug("HL:wallet");

export const walletService = writable(new NDKWallet(new NDK()));
export const wallet = writable<NDKCashuWallet|null>(null);

export const walletsBalance = writable(new Map<string, number>());
export const walletBalance = derived([wallet, walletsBalance], ([$wallet, $walletsBalance]) => {
    if (!$wallet) return 0;
    return $walletsBalance.get($wallet.walletId) || 0;
});

export const wallets = writable<NDKCashuWallet[]>([]);

export function walletInit(
    ndk: NDK,
    user: NDKUser
) {
    const $walletService = get(walletService);
    $walletService.ndk = ndk;
    $walletService.on("wallet", () => { wallets.set($walletService.wallets); });
    $walletService.on("wallet:default", (w: NDKCashuWallet) => {
        wallet.set(w);
        if (!ndk.walletConfig) ndk.walletConfig = {};
        ndk.walletConfig.onNutPay = onNutPay;
    });
    $walletService.on("wallet:balance", (w: NDKCashuWallet) => {
        walletsBalance.update((b) => {
            b.set(w.walletId, w.balance || 0);
            d("setting balance of wallet %s to %d", w.walletId, w.balance);
            return b;
        });
    });
    $walletService.start();
    
    d("fetching user wallets");

    ndk.walletConfig = {
        onLnPay,
        onPaymentComplete,
    }
}

async function onLnPay(details: NDKZapDetails<LnPaymentInfo>): Promise<NDKZapConfirmation> {
    const $wallet = get(wallet);
    const { amount, unit, target, comment } = details;
    const { pr } = details.info;

    const preimage = await $wallet?.lnPay(pr);
    if (!preimage) throw new Error("failed to pay");

    d("payment successful", preimage);

    return { preimage };
}

async function onNutPay(details: NDKZapDetails<NutPaymentInfo>): Promise<NDKZapConfirmation> {
    const $ndk = get(ndk);
    const $wallet = get(wallet);
    const { mints, p2pkPubkey, relays } = details.info;
    const { amount, unit, target, recipientPubkey, comment } = details;

    d("received Nut payment request", details);

    if (!$wallet) throw new Error("no wallet selected");

    const res = await $wallet.nutPay(amount, unit, mints, p2pkPubkey);
    if (!res) throw new Error("failed to pay");

    d("payment successful", res);

    const recipient = $ndk.getUser({pubkey: recipientPubkey })

    const nutzap = await $wallet.publishNutzap(res.proofs, res.mint, amount, unit, target, recipient, relays, comment);

    d("nutzap published", nutzap.rawEvent());

    return nutzap;
}

function onPaymentComplete(confirmation: NDKZapConfirmation | Error) {
    if (confirmation instanceof Error) {
        toast.error(confirmation.message);
        return;
    }
}