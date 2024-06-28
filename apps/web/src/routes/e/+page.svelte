<script lang="ts">
	import { page } from "$app/stores";
    import EventViewerText from "$views/EventViewerPage/Text.svelte";

    let id: string | null;

    $: id = $page.url.searchParams.get('eventId');
</script>

{#key id}
    {#if id}
        <EventViewerText {id} />
    {/if}
{/key}
