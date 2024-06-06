<script lang="ts">
	import FeedEvent from "./FeedEvent.svelte";
	import { getGAUserContent, getUserContent } from "$stores/user-view";
	import { derived } from "svelte/store";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { requiredTiersFor } from "$lib/events/tiers";

    const userContent = getUserContent();
    const userGAContent = getGAUserContent();

    const allContent = derived([userContent, userGAContent], ([$userContent, $userGAContent]) => {
        const ret = [...$userContent, ...$userGAContent]
            .sort((a, b) => b.created_at! - a.created_at!);

        return ret.filter((e: NDKEvent) => !requiredTiersFor(e).includes('Free'));
    });
</script>

<div class="flex flex-col w-full discussion-wrapper">
    {#each $allContent as event (event.id)}
        <FeedEvent {event} skipAuthor={true} />
    {/each}
</div>
