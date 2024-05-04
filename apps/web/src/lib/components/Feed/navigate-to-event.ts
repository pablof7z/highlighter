import { pushState } from "$app/navigation";
import NoteDetailView from "$components/DetailView/NoteDetailView.svelte";
import { detailView } from "$stores/layout";
import { NDKEvent } from "@nostr-dev-kit/ndk";

export function navigateToEvent(event: NDKEvent) {
    pushState(`/e/${event.encode()}`, {
        detailView: true,
    });
    detailView.set({
        component: NoteDetailView,
        props: { event }
    });
}