import { Readable, derived, get, writable } from "svelte/store";
import { networkFollows } from "./session";
import { NDKEvent, type Hexpubkey } from "@nostr-dev-kit/ndk";

// derived store where all user follows are present and network follows present in at least 3 follow lists
export const minimumScore = writable<number>(3);

export let wot: Readable<Set<string>> | undefined;

function initWot() {
    if (!networkFollows || !minimumScore) return;
    
    wot ??= derived([networkFollows, minimumScore], ([$networkFollows, $minimumScore]) => {
        const pubkeys = new Set<Hexpubkey>();
    
        $networkFollows.forEach((score: number, follow: Hexpubkey) => {
            if (score >= $minimumScore) pubkeys.add(follow);
        });
    
        return pubkeys;
    });
}

export function wotFilteredStore<T>(event: Readable<T[]>) {
    initWot();
    if (!wot) return event;
    
    return derived([event, wot], ([$event, $wot]) => {
        if ($wot.size < 1000) {
            
            return $event;
        }

        const filteredEvents: T[] = [];

        for (const e of $event) {
            if ($wot.has(e.pubkey)) filteredEvents.push(e);
        }

        return filteredEvents;
    });
}

export function wotFiltered(events: NDKEvent[]) {
    initWot();
    if (!wot) return events;

    const $wot = get(wot);

    if ($wot.size < 1000) return events;

    const filteredEvents: NDKEvent[] = [];

    for (const e of events) {
        if ($wot.has(e.pubkey)) filteredEvents.push(e);
    }

    return filteredEvents;
}

export const wotFilter = () => {
    const noop = (events: NDKEvent[]) => events;
    
    initWot();
    if (!wot) return noop;

    const $wot = get(wot);

    if ($wot.size < 1000) return noop;

    return (events: NDKEvent[]) => events.filter((e) => $wot.has(e.pubkey));
}

