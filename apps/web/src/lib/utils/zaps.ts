import { ndk } from "$stores/ndk.js";
import { Hexpubkey, NDKEvent, NDKFilter, NDKKind, NDKSubscriptionCacheUsage, NDKSubscriptionOptions, NDKUser, NDKZapInvoice, zapInvoiceFromEvent } from "@nostr-dev-kit/ndk";
import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
import { NDKNutzap } from "@nostr-dev-kit/ndk";
import { Readable, derived, get, readable } from "svelte/store";

export type ZapScore = { pubkey: Hexpubkey, totalSats: number, totalZaps: number, comments?: string[] };

export type UnsubscribableStore<T> = Readable<T> & { unsubscribe: () => void };
export type ZapInvoiceWithEvent = NDKZapInvoice & { event: NDKEvent };

/**
 * Create a filter to fetch zaps
 */
const filter = (
    eventOrUser: NDKEvent | NDKUser,
    extraFilter: NDKFilter = { limit: 100 }
): NDKFilter => {
    const filter: NDKFilter = { kinds: [NDKKind.Zap as number, NDKKind.Nutzap ], ...extraFilter };
    if (eventOrUser instanceof NDKUser) filter['#p'] = [eventOrUser.pubkey];
    else {
        filter['#e'] = [eventOrUser.id];
        if (eventOrUser.isParamReplaceable()) filter['#a'] = [eventOrUser.tagId()!];
    }

    console.log('zap filter', filter);
    
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
): UnsubscribableStore<NDKEvent[]> => {
    const $ndk = get(ndk);
    
    const store = $ndk.storeSubscribe(
        filter(eventOrUser, extraFilter),
        { subId: 'zaps', closeOnEose: true, ...subOpts}
    );

    // if (!zapperPubkey) return store;

    return {
        ...derived(store, $store => {
            return $store.filter(zap => {
                // if (zap.kind === NDKKind.Zap) return zap.pubkey === zapperPubkey;
                return true;
            });
        }),
        unsubscribe: store.unsubscribe
    };
}

/**
 * Get the top zaps for an event
 */
const topZapStore = (
    zapEvents: UnsubscribableStore<NDKEvent[]>,
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
        if (zap.kind === NDKKind.Zap) {
            const receipt = zapInvoiceFromEvent(zap);
            if (receipt && receipt.amount) receipts.push({event: zap, ...receipt});
        } else if (zap.kind === NDKKind.Nutzap) {
            const nutzap = NDKNutzap.from(zap);
            if (nutzap) {
                receipts.push({
                    event: zap,
                    amount: nutzap.amount,
                    zapped: nutzap.recipientPubkey,
                    zappee: nutzap.pubkey,
                    zapper: nutzap.pubkey,
                    comment: nutzap.comment,
                })
            }
        }
    }

    return receipts
        .sort((a, b) => b.event.created_at! - a.event.created_at!)
        .slice(0, count);
})

export function getTotalZapAmount(
    eventOrUser: NDKEvent | NDKUser,
    filter?: NDKFilter,
    opts?: NDKSubscriptionOptions
) {
    const zaps = zapsStore(eventOrUser, undefined, filter, opts);

    let store: Readable<number> & {
        events: Readable<NDKEvent[]>,
        unsubscribe: () => void
    };
    
    store = {
        events: zaps,
        
        unsubscribe: () => zaps.unsubscribe(),

        ...derived(zaps, $zaps => {
            return $zaps.reduce((acc, zap) => {
                const receipt = zapInvoiceFromEvent(zap);
                if (receipt && receipt.amount) acc += receipt.amount;
                return acc;
            }, 0);
    })};

    return store;
}


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

export const getZapperPubkey = async (eventOrUser: NDKEvent | NDKUser) => {
    const user = eventOrUser instanceof NDKUser ? eventOrUser : eventOrUser.author;
    return await user.getZapperPubkey();
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