import { NDKEvent } from "@nostr-dev-kit/ndk";

export function isScheduledEvent(event: NDKEvent) {
    const twoMinutesFromNow = Math.floor(Date.now() / 1000) + 120;
    return event.created_at! > twoMinutesFromNow;
}