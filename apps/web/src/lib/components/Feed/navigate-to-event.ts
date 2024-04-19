import { pushState } from "$app/navigation";
import { threeColumnLayoutRightSidebar } from "$stores/layout";
import { NDKEvent } from "@nostr-dev-kit/ndk";

export function navigateToEvent(event: NDKEvent) {
    pushState(`/e/${event.encode()}`, {
        detailView: true,
    });
    threeColumnLayoutRightSidebar.set({
        component: 'Note',
        props: { event }
    });
}