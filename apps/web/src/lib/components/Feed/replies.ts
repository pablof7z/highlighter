import { NDKEvent, NDKEventId, eventReplies, eventThreadIds, eventThreads } from "@nostr-dev-kit/ndk";
import { Readable, derived, get } from "svelte/store";

export function getThreadStore(
    op: NDKEvent,
    eventStore: Readable<NDKEvent[]>,
): Readable<NDKEvent[]> {
    return derived(eventStore, $eventStore => {
        return eventThreads(op, $eventStore);
    });
}

export function getRepliesStore(
    event: NDKEvent,
    eventStore: Readable<NDKEvent[]>,
    eventInThread: Readable<NDKEvent[]>,
): Readable<NDKEvent[]> {
    return derived(eventStore, $eventStore => {
        let threadIds = new Set<NDKEventId>();

        if (eventInThread) {
            threadIds = new Set(get(eventInThread).map((event: NDKEvent) => event.id));
        } else {
            threadIds = new Set(eventThreadIds(event, $eventStore).keys());
        }

        return eventReplies(event, $eventStore, threadIds);
    });
}

export function getConversationRepliesStore(
    op: NDKEvent,
    eventStore: Readable<NDKEvent[]>,
): Readable<NDKEvent[]> {
    return derived(eventStore, $eventStore => {
        const threadIds = eventThreadIds(op, $eventStore);

        return $eventStore
            .filter(event => !threadIds.has(event.id))
            .filter(event => event.getMatchingTags("e").some(tag => tag[1] === op.id));
    });
}