import NDK, { LnPaymentInfo, NDKPaymentConfirmation, NDKPaymentConfirmationCashu, NDKPaymentConfirmationLN, NDKUser, NDKZapConfirmation, NDKZapDetails, NDKZapSplit, NutPaymentInfo } from "@nostr-dev-kit/ndk";
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
    $walletService.on("wallet", (w) => wallets.set($walletService.wallets) );
    $walletService.on("wallet:default", (w: NDKCashuWallet) => {
        wallet.set(w);
        // w.on("insufficient_balance", (data) => {
        //     console.log("insufficient balance", data);
        // });
        ndk.walletConfig.onCashuPay = w.cashuPay.bind(w);
    });
    $walletService.on("wallet:balance", (w: NDKCashuWallet) => {
        walletsBalance.update((b) => {
            b.set(w.walletId, w.balance || 0);
            d("setting balance of wallet %s to %d", w.walletId, w.balance);
            return b;
        });
    });
    $walletService.start();
}

export async function onLnPay(details: NDKZapDetails<LnPaymentInfo>): Promise<NDKPaymentConfirmationLN | undefined> {
    const $wallet = get(wallet);
    const { amount, unit, target, comment, pr } = details;

    // do we have a NIP-60 wallet?

    try {
        const preimage = await $wallet?.lnPay({pr});
        if (!preimage) throw new Error("failed to pay");

        d("payment successful", preimage);

        return { preimage };
    } catch (e) {
        d("payment failed", e);

        throw e;
    }
}

export function onPaymentComplete(results: Map<NDKZapSplit, NDKPaymentConfirmation | Error | undefined>) {
    for (const [split, confirmation] of results) {
        if (confirmation instanceof Error) {
            toast.error(confirmation.message);
            return;
        }
    }
}