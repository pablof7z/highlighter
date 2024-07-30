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
    $walletService.on("wallet", (w) => { console.log('got wallet '+w.p2pkPubkey, w.rawEvent()); wallets.set($walletService.wallets); });
    $walletService.on("wallet:default", (w: NDKCashuWallet) => {
        console.log("setting default wallet", w);
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

    try {
        const preimage = await $wallet?.lnPay(pr);
        if (!preimage) throw new Error("failed to pay");

        d("payment successful", preimage);

        return { preimage };
    } catch (e) {
        d("payment failed", e);

        throw e;
    }
}

async function onNutPay(details: NDKZapDetails<NutPaymentInfo>): Promise<NDKZapConfirmation> {
    const $wallet = get(wallet);
    const { mints, p2pkPubkey } = details.info;
    const { amount, unit } = details;

    d("received Nut payment request", details);

    if (!$wallet) throw new Error("no wallet selected");

    try {
        const res = await $wallet.nutPay(amount, unit, mints, p2pkPubkey);
        if (!res) throw new Error("failed to pay");

        d("payment successful", res);

        const nutzap = await $wallet.publishNutzap(res.proofs, res.mint, details);

        d("nutzap published", nutzap.rawEvent());

        return nutzap;
    } catch (e) {
        d("payment failed", e);
        throw e;
    }
}

function onPaymentComplete(confirmation: NDKZapConfirmation | Error) {
    if (confirmation instanceof Error) {
        toast.error(confirmation.message);
        return;
    }
}