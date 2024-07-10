import { NDKEvent, NDKTag, type Hexpubkey } from "@nostr-dev-kit/ndk";
import { get } from "svelte/store";
import { ndk } from "../stores/ndk";
import { activeWallet, payWithProofs } from "../stores/cashu";

export type ZapSplit = [Hexpubkey, number, number];

export async function zap(
    amount: number,
    event: NDKEvent,
    comment?: string,
    splits?: ZapSplit[],
) {
    const $ndk = get(ndk);
    splits ??= getZapSplitsFromEvent(event);

    const $activeWallet = get(activeWallet);

    const totalSplitValue = splits.reduce((acc, split) => acc + split[1], 0);

    console.log('totalSplitValue', totalSplitValue, {splits});
    
    for (const zapSplit of splits) {
        const satAmount = Math.round(amount * zapSplit[1] / totalSplitValue);

        if (satAmount === 0) continue;
        
        $ndk
            .zap(event, satAmount * 1000, comment, [], $ndk.getUser({ pubkey: zapSplit[0] }))
            .then(async (pr: string | null) => {
                console.log('pr', pr);
                if (pr) {
                    // if ($walletBalance && $walletBalance >= satAmount) {
                        console.log("we can pay with wallet balance");

                        // try {
                            const ret = await payWithProofs(pr, satAmount, $activeWallet, event);
                            // console.log('trying to pay with wallet balance', proofs);
                            // const ret = await wallet.payLnInvoice(pr, proofs);
                            console.log({ret});
                            if (ret.isPaid) {
                                return ret;
                            }
                        // } catch (e) {
                        //     console.error(e);
                        //     toast.error(e.message);
                        // }
                }
            })
            // .catch((e: Error) => {
            //     console.error(e);
            //     newToasterMessage(e.message, "error");
            // })
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