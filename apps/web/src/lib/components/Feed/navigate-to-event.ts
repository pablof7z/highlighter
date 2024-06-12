import { pushState } from "$app/navigation";
import { NDKEvent } from "@nostr-dev-kit/ndk";

export function navigateToEvent(event: NDKEvent) {
    pushState(`/e/${event.encode()}`, {
    });
}