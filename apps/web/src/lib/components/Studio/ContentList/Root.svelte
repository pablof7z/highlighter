<script lang="ts">
	import { wrapEvent } from '$utils/event';
	import { NDKEvent } from '@nostr-dev-kit/ndk';
    import { inview } from 'svelte-inview';
	import { derived, Readable, writable } from 'svelte/store';
	import Item from './Item.svelte';
    
    export let content: Readable<NDKEvent[]>;
    export let renderLimit = 10;

    const deletedItems = writable(new Set<string>());

    const withoutDeletes = derived([content, deletedItems], ([$content, $deletedItems]) => {
        return $content
            .filter(c => !c.hasTag("deleted"))
            .filter(c => !$deletedItems.has(c.id));
    });

    const wrappedContent = derived(withoutDeletes, $content => $content.map(wrapEvent));
</script>

<div class="flex flex-col gap-4">
    {#each $wrappedContent.slice(0, renderLimit) as c (c.id)}
        {#if $$slots.default}
            <slot event={c} {deletedItems} />
        {:else}
            <Item event={c} {deletedItems} />
        {/if}
    {/each}

    <button on:click={() => { renderLimit++; }} use:inview on:inview_change={(e) => {
        if (e.detail.inView) {
            renderLimit += 5;
        }
    }} class:hidden={!$wrappedContent.length || renderLimit >= $wrappedContent.length}>
        load more
    </button>
</div>

