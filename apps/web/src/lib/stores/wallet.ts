import NDK, { LnPaymentInfo, NDKKind, NDKPaymentConfirmation, NDKPaymentConfirmationLN, NDKZapDetails, NDKZapSplit } from "@nostr-dev-kit/ndk";
import { NDKWallet, NDKCashuWallet, NDKWalletBalance } from "@nostr-dev-kit/ndk-wallet";
import { get, writable } from "svelte/store";
import createDebug from "debug";
import { toast } from "svelte-sonner";
import NDKWalletService from "@nostr-dev-kit/ndk-wallet";
import { type WalletConfig } from "./settings";

const d = createDebug("HL:wallet");

export const walletService = writable(new NDKWalletService(new NDK()));
export const wallet = writable<NDKWallet|null>(null);
export const walletBalances = writable<NDKWalletBalance[]>([]);

export const wallets = writable<NDKWallet[]>([]);

// function updateBalance(wallet: NDKWallet) {
//     wallet.balance().then((balance) => {
//         if (balance) {
//             walletsBalance.update((b) => {
//                 b.set(wallet.walletId, balance);
//                 d("setting balance of wallet %s to %d", wallet.walletId, balance);
//                 return b;
//             });
//         }
//     });
// }

export async function walletUnit() {
    wallet.set(null);
    walletBalances.set([]);
    // activeWallet.set(null);
}

export async function walletInit(
    ndk: NDK,
    walletConfig?: WalletConfig
) {
    if (walletConfig?.type === 'nip-60') {
        console.log({walletConfig})
        const walletEvent = await ndk.fetchEvent([{ kinds: [NDKKind.CashuWallet], "#d": [walletConfig.id!] }]);
        console.log('walletEvent', walletEvent?.rawEvent())
        if (!walletEvent) {
            throw new Error("wallet not found");
        }
        const w = await NDKCashuWallet.from(walletEvent);
        if (!w) {
            throw new Error("wallet not valid");
        }

        w.start();
        wallet.set(w);

        ndk.walletConfig!.onCashuPay = w.cashuPay.bind(w);
        
        w.on("balance_updated", () => walletBalances.set(w.balance() ?? []));
        w.on("balance_updated", () => console.log("balance updated", w.balance()));
    }
    
    // walletService.set(new NDKWalletService(ndk));
    // console.log('walletConfig', ndk.walletConfig)
    // const $walletService = get(walletService);
    // $walletService.ndk = ndk;
    // $walletService.on("wallet", (w) => {
    //     if (get(wallet) === null) wallet.set(w);
    //     wallets.set($walletService.wallets)
    //     w.on("balance_updated", () => updateBalance(w));
    //     updateBalance(w);
    // });
    // $walletService.on("wallet:default", (w: NDKCashuWallet) => {
    //     wallet.set(w);
    //     w.on("insufficient_balance", (data) => {
    //         if (data.pr) {
    //             openModal(LnQrModal, { pr: data.pr });
    //         } else {
    //             toast.error("insufficient balance" + JSON.stringify(data));
    //         }
    //     });
    // });
    // $walletService.on("wallet:balance", updateBalance);
    // $walletService.start();
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