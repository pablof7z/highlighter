import "websocket-polyfill";
import { ndk } from "$stores/ndk";
import { get } from 'svelte/store';
import { Hexpubkey, NDKEvent, NDKFilter, NDKKind, NDKSubscriptionCacheUsage, filterForEventsTaggingId } from "@nostr-dev-kit/ndk";
import { nip19 } from "nostr-tools";
import createDebug from 'debug';
import { DecodeResult } from "nostr-tools/nip19";

const d = createDebug('HL:ssr');

const timeout = (time: number) => new Promise((_, reject) => {
    setTimeout(() => {
        reject(new Error("Timeout"));
    }, time);
});

function chooseImageFromMediaEvents(mediaEvents: NDKEvent[], author: Hexpubkey) {
    let image: string | undefined;
    
    for (const media of mediaEvents) {
        const i = media.tagValue("url");
        if (i) {
            image = i;

            // if the author is the author of the media, we're done
            if (media.pubkey === author) break;
        }
    }

    return image;
}

export async function ssrFetchEventFromCache(idOrFilter: string | NDKFilter[]) {
    const $ndk = get(ndk);
    let event: NDKEvent | null | undefined;
    let image: string | undefined;
    const promises: Promise<any>[] = [];
    let decode: DecodeResult | undefined;

    d(`ssrFetchEventFromCache: %o`, idOrFilter);

    if (typeof idOrFilter === "string") {
        try {
            decode = nip19.decode(idOrFilter);
        } catch {}
    }

    if (typeof idOrFilter === "string") {
        try {
            promises.push(new Promise<void>(async (resolve, reject) => {
                event = await $ndk.fetchEvent(idOrFilter, {
                    cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE
                });
                d("Resolving cache event fetch")
                resolve();
            }));
        } catch {
            d("Failed to decode event id");
            return {};
        }
    } else {
        promises.push(new Promise<void>(async (resolve, reject) => {
            d("Fetching event from cache %o", idOrFilter)
            event = await $ndk.fetchEvent(idOrFilter, {
                cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE
            });
            d("Resolving cache event fetch %d", !!event)
            resolve();
        }));
    }

    try {
        if (decode?.type === "naddr") {
            const authorPubkey = decode.data.pubkey;
            promises.push(new Promise<void>(async (resolve, reject) => {
                const tagFilter: NDKFilter = filterForEventsTaggingId(idOrFilter);
                tagFilter.kinds = [NDKKind.Media];
                const mediaEvent = await $ndk.fetchEvents([
                    // one 1063 query by the author of the event
                    {...tagFilter, authors: [authorPubkey], limit: 1},

                    // a few extra just in case the author didn't publish one
                    {...tagFilter, limit: 5},
                ], {
                    cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE
                });

                image = chooseImageFromMediaEvents(Array.from(mediaEvent), authorPubkey);
                resolve();
            }));
        }

        d("waiting for promises %o", idOrFilter);
        await Promise.race([
            new Promise((resolve) => {
                Promise.all(promises).then(resolve);
            }),
            timeout(5000),
        ]).catch(() => d('caught'));
        d("promises done %o", idOrFilter);
    } catch (e) {
        console.trace(e)
        d("Failed to fetch event from cache");
        return {};
    }

    const ret: Record<any, any> = {};

    if (event) ret.event = event;
    if (image) ret.image = image;

    d("returning %o", { keys: Object.keys(ret)})

    return ret;
}

