<script lang="ts">
	import { page } from "$app/stores";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { appMobileHideNewPostButton } from "$stores/app";
	import { resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    let eventId: string | null;

    $: eventId = $page.url.searchParams.get('eventId');

    $appMobileHideNewPostButton = true;

    onDestroy(resetLayout);
</script>

{#if eventId}
    {#key eventId}
        <ItemView tagId={eventId} />
    {/key}
{/if}