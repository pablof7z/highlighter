<script lang="ts">
	import FeedEvent from "./FeedEvent.svelte";
	import { getGAUserContent, getUserContent } from "$stores/user-view";
	import { derived } from "svelte/store";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { debugMode } from "$stores/session";

    export let onlyBackstageContent = false;

    const userContent = getUserContent();
    const userGAContent = getGAUserContent();

    const allContent = derived([userContent, userGAContent], ([$userContent, $userGAContent]) => {
        const ret = [...$userContent, ...$userGAContent]
            .sort((a, b) => b.created_at! - a.created_at!);

        if (!onlyBackstageContent) return ret;

        for (const e of ret) {
            console.log('onlyBackstageContent', requiredTiersFor(e));
        }
        return ret.filter((e: NDKEvent) => !requiredTiersFor(e).includes('Free'));
    });
</script>

<div class="flex flex-col w-full discussion-wrapper">
    {#if $debugMode}
        onlyBackstageContent = {onlyBackstageContent}
    {/if}

    {#each $allContent as event (event.id)}
        <FeedEvent {event} skipAuthor={true} />
    {/each}
</div>

<style lang="postcss">
    :global(.article p) {
        @apply font-light text-white text-opacity-60 text-lg leading-7;
    }
</style>
