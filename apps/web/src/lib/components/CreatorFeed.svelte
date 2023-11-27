<script lang="ts">
	import { NDKArticle, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import type { Readable } from "svelte/store";
	import FeedEvent from "./Feed/FeedEvent.svelte";

    export let content: Readable<NDKEvent[]>;
</script>

<div class="flex flex-col max-w-xl mx-auto">
    {#each $content as event (event.id)}
        <FeedEvent {event} />
    {/each}
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
