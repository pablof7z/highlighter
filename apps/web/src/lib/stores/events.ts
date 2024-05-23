import NDK, { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
import { writable } from "svelte/store";

export type FailedPublishEntry = {event: NDKEvent, error: Error};

export let failedPublishEvents = writable<Map<NDKEventId, FailedPublishEntry>>(new Map());

export function initStoreEvent(ndk: NDK) {
    ndk.on('event:publish-failed', (event: NDKEvent, error: Error) => {
        if (event.kind === 15) return;
        
        failedPublishEvents.update((map) => {
            map.set(event.id, { event, error });
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