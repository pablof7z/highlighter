import { NDKEvent } from "@nostr-dev-kit/ndk";
/**
 * Wraps an event in a kind-specific class
 *
 * @param event - The event to wrap
 * @param gracefulFallback - Whether to return the event if the kind is not supported
 * @returns The wrapped event
 */
export declare function wrapEvent(event: NDKEvent, gracefulFallback?: boolean): NDKEvent;
