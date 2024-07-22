<script lang="ts">
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";
    import HorizontalList from "$components/PageElements/HorizontalList/List.svelte";

    export let items: Readable<any[]> = getContext("items");
    export let orientation: "horizontal" | "vertical" = "horizontal";
    export let title: string | undefined = undefined;
</script>

{#if orientation === "horizontal"}
    <HorizontalList {title} items={$items} />
{:else}
    {#each $items as item (item.id)}
        <slot {item} />
    {/each}
{/if}