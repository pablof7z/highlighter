import { Hexpubkey, NDKEvent, NDKEventId, eventIsReply, eventReplies, eventThreadIds, eventThreads } from "@nostr-dev-kit/ndk";
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
    op: NDKEvent,
): Readable<NDKEvent[]> {
    return derived(eventStore, $eventStore => {
        let threadIds = new Set<NDKEventId>();

        if (eventInThread) {
            threadIds = new Set(get(eventInThread).map((event: NDKEvent) => event.id));
        } else {
            threadIds = new Set(eventThreadIds(event, $eventStore).keys());
        }

        const replies = eventReplies(event, $eventStore, threadIds);

        // prioritize replies that have replies from the original author
        // console.log("Computing scores for", event.content.slice(0, 20).replace('\n', ''), "with ", replies.length, "replies");
        if (event.content.startsWith("it is")) {
            console.debug("Computing scores for", event.id);
            for (const reply of replies) {
                const score = computeScore(reply, $eventStore, event, op);
                console.debug(reply.content.slice(0, 30).replace(/\n/, ''), "           ", score);
            }
        }

        return replies.sort((a, b) => {
            const aScore = computeScore(a, $eventStore, event, op);
            const bScore = computeScore(b, $eventStore, event, op);

            return bScore - aScore;
        });
    });
}

/**
 * @param e Event to score
 * @param events All the events that are tagging this conversation
 * @param originalAuthor The author of the original event
 * @param op The original event that started this conversation
 * @returns
 */
export function computeScore(
    e: NDKEvent,
    events: NDKEvent[],
    primaryEvent: NDKEvent,
    op: NDKEvent,
): number {
    let score = 1;

    const eReplies = eventReplies(e, events, new Set());

    // go through the events that are replies to e
    for (const eReply of eReplies) {
        score += computeScore(eReply, events, primaryEvent, op);
    }

    // if e is by the op, add 20 points
    if (e.pubkey === op.pubkey) {
        score += 20;
    }

    // if e is by the primary author, add 10 points
    if (e.pubkey === primaryEvent.pubkey) {
        score += 10;
    }

    return score;
}

export function getConversationRepliesStore(
    op: NDKEvent,
    eventStore: Readable<NDKEvent[]>,
): Readable<NDKEvent[]> {
    return derived(eventStore, $eventStore => {
        const threadIds = eventThreadIds(op, $eventStore);

        return $eventStore
            .filter(event => !threadIds.has(event.id))
            .filter(event => eventIsReply(op, event))
            // .sort((a, b) => a.created_at! - b.created_at!);
    });
}