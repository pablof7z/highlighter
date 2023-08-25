import { persist, createLocalStorage } from "@macfja/svelte-persistent-store";
import { writable, get as getStore, type Readable, derived } from "svelte/store";
import { userTaggedEvents } from "./jobRequests";
import type { NDKEvent } from "@nostr-dev-kit/ndk";

export const seenIds = persist(
    writable<Set<string>>(new Set()),
    createLocalStorage(),
    "seen-ids",
);

export const lastSeenTimestamp = persist(
    writable<number>(),
    createLocalStorage(),
    "last-seen-timestamp",
);

export let unseenEvents: Readable<NDKEvent[]> | undefined;
export const notificationsEnabled = writable(false);

export function initNotifications() {
    if (!userTaggedEvents) {
        throw new Error("User tagged events not initialized");
    }

    console.log(`Initializing notifications`);

    // unseenEvents = derived(userTaggedEvents, $userTaggedEvents => {
    //     const $seenIds = getStore(seenIds);
    //     const $lastSeenTimestamp = getStore(lastSeenTimestamp)
    //     const timestampThreshold = Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 1

    //     // if (!$lastSeenTimestamp) {
    //     //     return $userTaggedEvents;
    //     // }

    //     return $userTaggedEvents.filter(event => {
    //         return event.created_at! > timestampThreshold && !$seenIds?.has(event.id);
    //     });
    // });

    setTimeout(() => {
        notificationsEnabled.set(true);
    }, 1000);
}


export function markEventAsSeen(eventId: string) {
    console.log(`Marking event ${eventId} as seen`);
    seenIds.update($seenIds => {
        $seenIds.add(eventId);
        return $seenIds;
    });
}