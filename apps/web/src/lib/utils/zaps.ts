import { ndk } from "@kind0/ui-common";
import { Hexpubkey, NDKEvent, NDKFilter, NDKKind, NDKSubscriptionCacheUsage, NDKSubscriptionOptions, NDKUser, NDKZap, NDKZapInvoice, zapInvoiceFromEvent } from "@nostr-dev-kit/ndk";
import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
import { Readable, derived, get, readable } from "svelte/store";

export type ZapScore = { pubkey: Hexpubkey, totalSats: number, totalZaps: number, comments?: string[] };

export type UnsubscribableStore<T> = Readable<T> & { unsubscribe: () => void };
export type ZapInvoiceWithEvent = NDKZapInvoice & { event: NDKEvent };

/**
 * Create a filter to fetch zaps
 */
const filter = (
    eventOrUser: NDKEvent | NDKUser,
    zapperPubkey?: Hexpubkey,
    extraFilter: NDKFilter = { limit: 100 }
): NDKFilter => {
    const filter: NDKFilter = { kinds: [NDKKind.Zap as number], ...extraFilter };
    if (eventOrUser instanceof NDKUser) filter['#p'] = [eventOrUser.pubkey];
    else filter['#e'] = [eventOrUser.id];
    if (zapperPubkey) filter['authors'] = [zapperPubkey];
    return filter;
}

/**
 * Create a store to receive zaps
 */
const zapsStore = (
    eventOrUser: NDKEvent | NDKUser,
    zapperPubkey?: Hexpubkey,
    extraFilter?: NDKFilter,
    subOpts?: NDKSubscriptionOptions,
) => {
    return get(ndk).storeSubscribe(
        filter(eventOrUser, zapperPubkey, extraFilter),
        { cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE, closeOnEose: true, ...subOpts}
    );
}

/**
 * Get the top zaps for an event
 */
const topZapStore = (
    zapEvents: NDKEventStore<NDKEvent>,
    count: number
) => derived(zapEvents, $zapEvents => {
    const receipts: ZapInvoiceWithEvent[] = [];

    for (const zap of $zapEvents) {
        const receipt = zapInvoiceFromEvent(zap);
        if (receipt && receipt.amount) receipts.push({event: zap, ...receipt});
    }

    return receipts
        .sort((a, b) => b.amount - a.amount)
        .slice(0, count);
})

const aggregatedTopZapStore = (
    zapEvents: NDKEventStore<NDKEvent>,
    count: number,
    countType: 'sats' | 'zaps' = 'sats'
) => derived(zapEvents, $zapEvents => {
    const perPubkeyScore = new Map<Hexpubkey, ZapScore>();
    for (const zap of $zapEvents) {
        const receipt = zapInvoiceFromEvent(zap);
        if (receipt && receipt.amount) {
            const score = perPubkeyScore.get(receipt.zappee) || { pubkey: receipt.zappee, totalSats: 0, totalZaps: 0 };
            score.totalSats += receipt.amount;
            score.totalZaps++;
            perPubkeyScore.set(receipt.zappee, score);
        }
    }

    let ret = Array.from(perPubkeyScore.values())

    if (countType === 'zaps')
        ret = ret.sort((a, b) => b.totalZaps - a.totalZaps)
    else
        ret = ret.sort((a, b) => b.totalSats - a.totalSats)

    return ret.slice(0, count);
});

/**
 * Get the most recent zaps for an event
 */
const mostRecentZapsStore = (
    zapEvents: NDKEventStore<NDKEvent>,
    count: number
) => derived(zapEvents, $zapEvents => {
    const receipts: ZapInvoiceWithEvent[] = [];

    for (const zap of $zapEvents) {
        const receipt = zapInvoiceFromEvent(zap);
        if (receipt && receipt.amount) receipts.push({event: zap, ...receipt});
    }

    return receipts
        .sort((a, b) => b.event.created_at! - a.event.created_at!)
        .slice(0, count);
})


/**
 * Gets the top zaps, sorted by individual amount
 * @param event
 * @param count
 * @returns
 */
export async function getTopZapsByIndividualAmount(
    eventOrUser: NDKEvent | NDKUser,
    count: number,
): Promise<UnsubscribableStore<ZapInvoiceWithEvent[]>> {
    const zaps = zapsStore(eventOrUser, await getZapperPubkey(eventOrUser));
    const topZaps = topZapStore(zaps, count);

    return { ...topZaps, unsubscribe: () => zaps.unsubscribe() };
}

const getZapperPubkey = async (eventOrUser: NDKEvent | NDKUser) => {
    const $ndk = get(ndk);
    return await NDKZap.getZapperPubkey($ndk, eventOrUser.pubkey);
}

/**
 * Gets the most recent zaps for an event
 * @param event
 * @param count
 * @returns
 */
export async function getRecentZaps(
    eventOrUser: NDKEvent | NDKUser,
    count: number,
): Promise<UnsubscribableStore<ZapInvoiceWithEvent[]>> {
    const zaps = zapsStore(eventOrUser, await getZapperPubkey(eventOrUser));
    const recentZaps = mostRecentZapsStore(zaps, count);

    return { ...recentZaps, unsubscribe: () => zaps.unsubscribe() };
}

/**
 * Returns the top zap, followed by the most recent zaps
 * @param event
 * @param count
 * @returns
 */
export async function topPlusRecentZaps(
    eventOrUser: NDKEvent | NDKUser,
    count: number,
    filter?: NDKFilter,
    subOpts?: NDKSubscriptionOptions
) {
    const zaps = zapsStore(eventOrUser, await getZapperPubkey(eventOrUser), filter, subOpts);
    const topZaps = topZapStore(zaps, 1);
    const recentZaps = mostRecentZapsStore(zaps, count);

    const recentZapsWithTopZapFirst = derived([zaps, topZaps, recentZaps], ([$zaps, $topZaps, $recentZaps]) => {
        // console.log(`called with ${$zaps.length} zaps, ${$topZaps.length} top zaps, ${$recentZaps.length} recent zaps`)
        const ret = $recentZaps.filter(zap => $topZaps[0]?.event.id !== zap.event.id);


        // prepend the top zap to the list if there is one
        if ($topZaps[0]) ret.unshift($topZaps[0]);

        return ret;
    });

    return {
        ...recentZapsWithTopZapFirst,
        unsubscribe: () => zaps.unsubscribe()
    }
}

export async function getTopZapsByAggregatedAmount(
    eventOrUser: NDKEvent | NDKUser,
    count: number,
) {
    const zaps = zapsStore(eventOrUser, await getZapperPubkey(eventOrUser));
    const topZaps = aggregatedTopZapStore(zaps, count);

    return { ...topZaps, unsubscribe: () => zaps.unsubscribe() };
}