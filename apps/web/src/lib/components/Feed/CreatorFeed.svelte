<script lang="ts">
    import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import FeedEvent from "./FeedEvent.svelte";
	import { isRootEvent } from "$utils/event";

    export let content: Readable<NDKEvent[]>;
    export let contentGA: Readable<NDKEvent[]>;

    const rootContent = derived(content, ($content) => {
        return $content.filter(isRootEvent);
    });

    $: console.log('$contentGA', $contentGA?.length);
</script>

<div class="flex flex-col max-w-xl gap-10">
    {#if $rootContent?.length > 0}
        {#each $rootContent as event (event.id)}
            <FeedEvent {event} />
        {/each}
    {:else if $contentGA?.length > 0}
        {$contentGA.length}
        {#each $contentGA as event (event.id)}
            <FeedEvent {event} />
        {/each}
    {/if}
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
