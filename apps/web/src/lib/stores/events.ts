import NDK, { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
import { get, writable } from "svelte/store";

export type FailedPublishEntry = {event: NDKEvent, relays?: WebSocket["url"][], error: Error};

export let failedPublishEvents = writable<Map<NDKEventId, FailedPublishEntry>>(new Map());

export function initStoreEvent(ndk: NDK) {
    if (ndk.cacheAdapter?.getUnpublishedEvents) {
        ndk.cacheAdapter?.getUnpublishedEvents().then((events) => {
            failedPublishEvents.update((map) => {
                events.forEach((event) => {
                    const e = event.event;
                    e.ndk = ndk;
                    map.set(e.id, { event: e, relays: event.relays, error: new Error('Unpublished event') });
                });
                return map;
            });
        });
    }
    
    ndk.on('event:publish-failed', (event: NDKEvent, error: Error, relays: WebSocket["url"][]) => {
        if (event.kind === 15) return;
        
        failedPublishEvents.update((map) => {
            map.set(event.id, { event, relays, error });
            return map;
        });

        event.on('publish', () => {
            failedPublishEvents.update((map) => {
                map.delete(event.id);
                return map;
            });
        });
    });
}