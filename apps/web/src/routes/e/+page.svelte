<script lang="ts">
	import { page } from "$app/stores";
    import EventViewerText from "$views/EventViewerPage/Text.svelte";

    let id: string | null;

    $: id = $page.url.searchParams.get('eventId');
    
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
    {#if id}
        <EventViewerText {id} />
    {/if}
{/key}
