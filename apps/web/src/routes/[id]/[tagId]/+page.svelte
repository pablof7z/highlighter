<script lang="ts">
	import { loadedEvent } from "./store.js";
	import { onDestroy } from "svelte";
	import { pageHeader } from "$stores/layout";
	import ItemHeader from "$components/ItemHeader.svelte";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";

    $pageHeader ??= {};
    $pageHeader.component = ItemHeader;
    $: $pageHeader.props = {
        item: $loadedEvent,
        class: "max-w-[var(--content-focused-width)] mx-auto w-full"
    }

    onDestroy(() => {
        if ($pageHeader?.component)
            $pageHeader.component = undefined;
    })

</script>

{#if $loadedEvent}
    <ItemView event={$loadedEvent} ignoreHeader={true} />
{/if}