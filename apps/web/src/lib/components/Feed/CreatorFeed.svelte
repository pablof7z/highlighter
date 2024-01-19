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
</script>

<div class="flex flex-col w-full gap-10">
    {#if $rootContent?.length > 0}
        {#each $rootContent as event (event.id)}
            <FeedEvent {event} skipAuthor={true} />
        {/each}
    {:else if $contentGA?.length > 0}
        {#each $contentGA as event (event.id)}
            <FeedEvent {event} skipAuthor={true} />
        {/each}
    {/if}
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
