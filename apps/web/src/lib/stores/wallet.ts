import NDK, { LnPaymentInfo, NDKPaymentConfirmation, NDKPaymentConfirmationLN, NDKZapDetails, NDKZapSplit } from "@nostr-dev-kit/ndk";
import NDKWallet, { NDKCashuWallet, NDKWalletBalance } from "@nostr-dev-kit/ndk-wallet";
import { derived, get, writable } from "svelte/store";
import createDebug from "debug";
import { toast } from "svelte-sonner";
import NDKWalletService, { NDKWebLNWallet } from "@nostr-dev-kit/ndk-wallet";

const d = createDebug("HL:wallet");

export const walletService = writable(new NDKWalletService(new NDK()));
export const wallet = writable<NDKWallet|null>(null);

export const walletsBalance = writable(new Map<string, NDKWalletBalance[]>());
export const walletBalance = derived([wallet, walletsBalance], ([$wallet, $walletsBalance]) => {
    if (!$wallet) return [];
    return $walletsBalance.get($wallet.walletId!) || [];
});

export const wallets = writable<NDKWallet[]>([]);

function updateBalance(wallet: NDKWallet) {
    wallet.balance().then((balance) => {
        if (balance) {
            walletsBalance.update((b) => {
                b.set(wallet.walletId, balance);
                d("setting balance of wallet %s to %d", wallet.walletId, balance);
                return b;
            });
        }
    });
}

export function walletInit(
    ndk: NDK,
) {
    walletService.set
    const $walletService = get(walletService);
    $walletService.ndk = ndk;
    $walletService.on("wallet", (w) => {
        if (get(wallet) === null) wallet.set(w);
        wallets.set($walletService.wallets)
        w.on("balance_updated", () => updateBalance(w));
        updateBalance(w);
    });
    $walletService.on("wallet:default", (w: NDKCashuWallet) => {
        wallet.set(w);
        w.on("insufficient_balance", (data) => {
            alert("insufficient balance" + data);
        });
    });
    $walletService.on("wallet:balance", updateBalance);
    $walletService.start();
}

export async function onLnPay(details: NDKZapDetails<LnPaymentInfo>): Promise<NDKPaymentConfirmationLN | undefined> {
    const $wallet = get(wallet);
    const { amount, unit, target, comment, pr } = details;

    // do we have a NIP-60 wallet?

    try {
        toast.info("wallet balance: "+ $wallet?.balance);
        
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