import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
import { derived, Readable } from "svelte/store";
import { chronologically } from "$utils/event";

export type NDKEventWithFrom<T> = { from?: (event: NDKEvent) => T, kind?: NDKKind, kinds?: NDKKind[]};

export function deriveStore<T>(
    store: Readable<NDKEvent[]>,
    klass?: NDKEventWithFrom<T>,
    kinds?: NDKKind[]
): Readable<T[]> {
    kinds ??= klass?.kinds;
    if (!kinds && klass?.kind) kinds = [klass.kind];
    if (!kinds) throw new Error("No kinds provided and none could be inferred from the class");

    return derived(store, $events => {
        const filtered = $events.filter(event => kinds!.includes(event.kind!));

        if (kinds.includes(37001)) console.log('looking for', kinds, 'found', filtered.length, 'events', $events.map(e => e.kind));

        if (klass?.from)
            return filtered.map(e => klass.from!(e));
        else 
            return filtered as unknown as T[];
    });
}

export function deriveListStore<T>(
    store: Readable<NDKEvent[]>,
    klass?: NDKEventWithFrom<T>,
    kinds?: NDKKind[]
): Readable<T | undefined> {
    kinds ??= klass?.kinds;
    if (!kinds && klass?.kind) kinds = [klass.kind];
    if (!kinds) throw new Error("No kinds provided and none could be inferred from the class");

    return derived(store, $events => {
        const lists = $events.filter(event => kinds!.includes(event.kind!));
        const event = lists.sort(chronologically)[0];
        return event ? klass?.from!(event) : undefined;
    })
}