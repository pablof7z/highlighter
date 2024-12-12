import { NDKEvent, NDKArticle, NDKKind } from "@nostr-dev-kit/ndk";

/**
 * Wraps an event in a kind-specific class
 * 
 * @param event - The event to wrap
 * @param gracefulFallback - Whether to return the event if the kind is not supported
 * @returns The wrapped event
 */
export function wrapEvent(event: NDKEvent, gracefulFallback: boolean = false) {
    switch (event.kind) {
        case NDKKind.Article: return NDKArticle.from(event);
        default:
            if (gracefulFallback) {
                return event;
            }

            throw new Error(`Unknown event kind: ${event.kind}`);
    }
}