import NDK, { NDKEvent, NDKPrivateKeySigner, NDKSigner, NDKTag, NDKUser, type Hexpubkey } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { ndk } from "../stores/ndk";
import { mintBalances, activeWallet, payWithProofs, chooseProofs, rollOverProofs } from "../stores/cashu";
import { NDKCashuWallet } from "./cashu/wallet";
import { CashuMint, CashuWallet, getEncodedToken } from "@cashu/cashu-ts";
import { NDKCashuToken } from "./cashu/token";

export type ZapSplit = [Hexpubkey, number, number];

export async function receiveCashuZap(
    event: NDKEvent,
    signer: NDKPrivateKeySigner,
    ndk: NDK
) {
    const proofs = JSON.parse(event.content)

    const mint = event.getMatchingTags("mint")[0][1];

    if (!mint) {
        throw new Error("No mint found in event");
    }
    
    const wallet = new CashuWallet(new CashuMint(mint));

    console.log("receiving with privkey", signer.privateKey, proofs);
    const receive = await wallet.receiveTokenEntry({ mint, proofs }, {
        privkey: signer.privateKey
    });

    const tokenEvent = new NDKCashuToken(ndk);
    tokenEvent.proofs = receive;
    tokenEvent.mint = mint;
    return tokenEvent;
}

export async function lnZap() {

}

export async function recv() {
    const payload =
        {
            "amount": 1,
            "C": "02b6096143568e181c01e5cd857e8c17a52660b095b99d8da00cf98f3bd88896e7",
            "id": "9mlfd5vCzgGl",
            "secret": "[\"P2PK\",{\"nonce\":\"ba4a7485e6ab7b53d0c5e4ba785cca17b4a4c187284a2b542ce08531371ddab8\",\"data\":\"02eaee8939e3565e48cc62967e2fde9d8e2a4b3ec0081f29eceff5c64ef10ac1ed\"}]"
        }

    const mint = "https://mint.minibits.cash/Bitcoin";
    const wallet = new CashuWallet(new CashuMint('https://mint.minibits.cash/Bitcoin'));
    const privkey = "152d8c7b7a4a5a46a39a3e07adb0c3e44f4903f7102ec7b195e2491900e5c129"

    const r = await wallet.receiveTokenEntry({ mint, proofs: [payload] }, {
        privkey: privkey,
    });
}

// export async function sendZap(
//     proofs: Proof[],
// ) {

// }

export async function cashuZap(
    amount: number,
    pubkey: Hexpubkey,
    mint: string,
    target: NDKEvent | NDKUser,
    comment?: string,
) {
    const wallet = new CashuWallet(new CashuMint(mint));
    const $activeWallet = get(activeWallet);

    const proofs = await chooseProofs(amount, $activeWallet.dTag, mint);
    console.log('proofs', proofs);

    // const p = "eaee8939e3565e48cc62967e2fde9d8e2a4b3ec0081f29eceff5c64ef10ac1ed";
    // const privkey = "152d8c7b7a4a5a46a39a3e07adb0c3e44f4903f7102ec7b195e2491900e5c129"

    const send = await wallet.send(amount, proofs.proofsToUse, {
        pubkey: '02'+pubkey,
    });
    console.log('send res', send);

    const $ndk = get(ndk);
    const zapEvent = new NDKEvent($ndk)
    zapEvent.kind = 7377;
    zapEvent.content = JSON.stringify(send.send);
    zapEvent.tags.push(["mint", mint]);

    zapEvent.tag(target);
    if (comment) zapEvent.tags.push(["comment", comment]);
    
    const ret = await zapEvent.publish();
    console.log('zapEvent', zapEvent.rawEvent(),);

    await rollOverProofs(proofs, send.returnChange, mint);
}

type ZapInfo = {
    method: 'ln' | 'cashu',

    pr?: string, // ln payment request
    mint?: string, // cashu mint
}

export async function getZapInfo(
    amount: number,
    pubkey: Hexpubkey,
) {//Promise<"ln" | "cashu"> {

    return {
        method: "cashu",
        mint: "https://mint.agorist.space",
    };
    
    const $ndk = get(ndk);
    const wallets = await $ndk.fetchEvents({ kinds: [37375], authors: [pubkey]});
    let info: ZapInfo;

    console.log('wallets for ' + pubkey, wallets.size);

    if (wallets.size > 0) {
        info = {
            method: "cashu",
        };

        const targetMints = new Set();
        for (const wallet of Array.from(wallets)) {
            for (const tag of wallet.getMatchingTags("mint")) {
                targetMints.add(tag[1]);
            }
        }

        console.log('mints', Array.from(targetMints));
        console.log('my mints', Array.from(get(mintBalances).keys()));

        // go through my wallets and see if I have a cashu wallet with the same mint with enough balance
        let mint: string | undefined;
        const $mintBalances = get(mintBalances);
        for (const [_mint, balance] of $mintBalances) {
            console.log('checking mint', _mint, balance, { required: amount })
            if (balance >= amount && targetMints.has(_mint)) {
                mint = _mint;
                break;
            }
        }

        console.log('found compatible mint?', mint);
        if (mint) {
            info.mint = mint;
        }
    }
    
    return info;
}

export async function zap(
    amount: number,
    target: NDKEvent | NDKUser,
    comment?: string,
    splits?: ZapSplit[],
) {
    const $ndk = get(ndk);

    if (target instanceof NDKEvent) {
        splits ??= getZapSplitsFromEvent(target);
    } else {
        splits ??= [[target.pubkey, 1, 0]];
    }

    const totalSplitValue = splits.reduce((acc, split) => acc + split[1], 0);

    console.log('totalSplitValue', totalSplitValue, {splits});
    
    for (const zapSplit of splits) {
        const satAmount = Math.round(amount * zapSplit[1] / totalSplitValue);

        if (satAmount === 0) continue;

        const zapInfo = await getZapInfo(satAmount, zapSplit[0]);

        if (zapInfo.method === 'cashu') {
            cashuZap(satAmount, zapSplit[0], zapInfo.mint!, target, comment)
        }
        
        // $ndk
        //     .zap(event, satAmount * 1000, comment, [], $ndk.getUser({ pubkey: zapSplit[0] }))
        //     .then(async (pr: string | null) => {
        //         console.log('pr', pr);
        //         if (pr) {
        //             // if ($walletBalance && $walletBalance >= satAmount) {
        //                 console.log("we can pay with wallet balance");

        //                 // try {
        //                     const ret = await payWithProofs(pr, satAmount, $activeWallet, event);
        //                     // console.log('trying to pay with wallet balance', proofs);
        //                     // const ret = await wallet.payLnInvoice(pr, proofs);
        //                     console.log({ret});
        //                     if (ret.isPaid) {
        //                         return ret;
        //                     }
        //                 // } catch (e) {
        //                 //     console.error(e);
        //                 //     toast.error(e.message);
        //                 // }
        //         }
        //     })
        //     // .catch((e: Error) => {
        //     //     console.error(e);
        //     //     newToasterMessage(e.message, "error");
        //     // })
    }
}

export function getZapSplitsFromEvent(event: NDKEvent): ZapSplit[] {
    const splits: ZapSplit[] = event.getMatchingTags("zap")
        .map((zapTag: NDKTag) => {
            return [zapTag[1], parseInt(zapTag[3]??"1"), 0]
        });
    
    if (splits.length === 0) {
        splits.push([event.pubkey, 1, 0]);
    }
    
    return splits;
}