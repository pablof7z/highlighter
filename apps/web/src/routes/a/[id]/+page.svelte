<script lang="ts">
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { resetLayout } from "$stores/layout";
	import ItemShell from "$views/ItemShell.svelte";
	import { onDestroy } from "svelte";
	import { appMobileHideNewPostButton } from "$stores/app";
	import { loadedEvent, title } from "$stores/item-view";

    let event;
    $: event = $loadedEvent;

    $appMobileHideNewPostButton = true;
    
    onDestroy(resetLayout);
</script>

{#if event}
    <ItemShell {event} title={$title}>
        <ItemView {event}  />
    </ItemShell>
{/if}