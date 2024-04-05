import { ndk } from "@kind0/ui-common";
import { Hexpubkey, NDKEvent, NDKKind, NDKZap, NDKZapInvoice, zapInvoiceFromEvent } from "@nostr-dev-kit/ndk";
import { Readable, derived, get, readable } from "svelte/store";

export type ZapScore = { pubkey: Hexpubkey, totalSats: number, totalZaps: number, comments?: string[] };

export type UnsubscribableStore<T> = Readable<T> & { unsubscribe: () => void };
export type ZapInvoiceWithEvent = NDKZapInvoice & { event: NDKEvent };

/**
 * Gets the most recent zaps for an event
 * @param event
 * @param count
 * @returns
 */
export async function getRecentZaps(
    event: NDKEvent,
    count: number,
): Promise<UnsubscribableStore<ZapInvoiceWithEvent[]>> {
    const $ndk = get(ndk);
    const zapperPubkey = await NDKZap.getZapperPubkey($ndk, event.pubkey);

    if (!zapperPubkey) return {
        ...readable([]),
        unsubscribe: () => {},
    }

    const filter = { kinds: [NDKKind.Zap as number], '#e': [event.id] };
    const zaps = $ndk.storeSubscribe(filter);

    const recentZaps = derived(zaps, $zaps => {
        const receipts: ZapInvoiceWithEvent[] = [];

        for (const zap of $zaps) {
            const receipt = zapInvoiceFromEvent(zap);
            if (receipt) {
                if ((zapperPubkey && receipt.zapper === zapperPubkey) || !zapperPubkey) {
                    receipts.push({event: zap, ...receipt});
                }
            }
        }

        return receipts.sort((a, b) => b.event.created_at! - a.event.created_at!).slice(0, count);
    });

    return { ...recentZaps, unsubscribe: () => zaps.unsubscribe() };
}

/**
 * Gets the top zaps, sorted by individual amount
 * @param event
 * @param count
 * @returns
 */
export async function getTopZapsByIndividualAmount(
    event: NDKEvent,
    count: number,
): Promise<UnsubscribableStore<ZapInvoiceWithEvent[]>> {
    const $ndk = get(ndk);
    const zapperPubkey = await NDKZap.getZapperPubkey($ndk, event.pubkey);

    if (!zapperPubkey) return {
        ...readable([]),
        unsubscribe: () => {},
    }

    const filter = { kinds: [NDKKind.Zap as number], '#e': [event.id] };

    const zaps = $ndk.storeSubscribe(filter);

    const topZaps = derived(zaps, $zaps => {
        const receipts: ZapInvoiceWithEvent[] = [];

        // case 'highest-sat-aggregate': {
        //     const perPubkeyScore = new Map<Hexpubkey, ZapScore>();

        //     for (const zap of $zaps) {
        //         const receipt = zapInvoiceFromEvent(zap);
        //         if (receipt) {
        //             if (
        //                 (zapperPubkey && receipt.zapper === zapperPubkey) ||
        //                 !zapperPubkey
        //             ) {
        //                 receipts.push(receipt);
        //                 const currentScore = perPubkeyScore.get(receipt.zappee) || { totalSats: 0, totalZaps: 0 };
        //                 perPubkeyScore.set(receipt.zappee, {
        //                     totalSats: currentScore.totalSats + receipt.amount,
        //                     totalZaps: currentScore.totalZaps + 1,
        //                     pubkey: receipt.zappee,
        //                 });
        //             }
        //         }
        //     }

        //     // get the top ten pubkeys with the most amount of sats
        //     const sortedScores = Array.from(perPubkeyScore.entries())
        //         .sort((a, b) => b[1].totalSats - a[1].totalSats)
        //         .slice(0, count);
        //     return sortedScores.map(([pubkey, score]) => ({ ...score, pubkey }));
        // }

        for (const zap of $zaps) {
            const receipt = zapInvoiceFromEvent(zap);
            if (receipt) {
                if ((zapperPubkey && receipt.zapper === zapperPubkey) || !zapperPubkey) {
                    receipts.push({
                        event: zap,
                        ...receipt});
                }
            }
        }

        return receipts.sort((a, b) => b.amount - a.amount).slice(0, count);
    });

    return {
        ...topZaps,
        unsubscribe: () => zaps.unsubscribe(),
    };
}