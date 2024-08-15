<script lang="ts">
	import { getContext } from "svelte";
	import { derived, Readable } from "svelte/store";
    import HorizontalList from "$components/PageElements/HorizontalList/List.svelte";
	import { eventToKind } from "$utils/event";

    export let items: Readable<any[]> = getContext("items");
    export let orientation: "horizontal" | "vertical" = "horizontal";
    export let title: string | undefined = undefined;

    const wrappedItems = derived(items, $items => $items.map(eventToKind));
</script>

{#if orientation === "horizontal"}
    <HorizontalList {title} items={$items} />
{:else}
    <div class="flex flex-col divide-y divide-border">
        {#each $wrappedItems as item (item.id)}
            <div class="w-full py-[var(--section-vertical-padding)]">
                <slot {item} />
            </div>
        {/each}
    </div>
{/if}