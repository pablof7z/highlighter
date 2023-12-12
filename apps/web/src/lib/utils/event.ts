import type { NDKEvent } from "@nostr-dev-kit/ndk";

/**
 * Checks whether the event is a root event.
 */
export function isRootEvent(event: NDKEvent): boolean {
    return !event.tagValue("e");
}