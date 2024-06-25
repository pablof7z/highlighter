<script lang="ts">
	import { page } from "$app/stores";
	import { NDKArticle, NDKEvent, NDKList, NDKVideo } from "@nostr-dev-kit/ndk";
    import EventViewerText from "$views/EventViewerPage/Text.svelte";

    let id: string;
    let event: NDKEvent | NDKArticle | NDKList | NDKVideo | undefined | null;
    
    $: if (id !== $page.params.id) {
        id = $page.params.id;

        // $ndk.fetchEvent(id).then((e) => {
        //     event = e ? eventToKind(e) : null;
        // });
    }

    // $: if (event) {
    //     const author = event.author;

    //     if (event.kind === event.dTag) {
    //         const authorUrl = getAuthorUrlSync(author);
    //         goto(`${authorUrl}/${event.dTag}`);
    //     }
    // }

    // onDestroy(resetLayout);
</script>

{#key id}
    <EventViewerText id={id} />
{/key}
