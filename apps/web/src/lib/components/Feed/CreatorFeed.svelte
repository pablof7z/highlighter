<script lang="ts">
    import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import FeedEvent from "./FeedEvent.svelte";
	import { isRootEvent } from "$utils/event";

    export let content: Readable<NDKEvent[]>;

    const rootContent = derived(content, ($content) => {
        return $content.filter(isRootEvent);
    });
</script>

<div class="flex flex-col max-w-xl gap-10">
    {#each $rootContent as event (event.id)}
        <FeedEvent {event} />
    {/each}
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
