<script lang="ts">
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import StylishContainer from "$components/PageElements/StylishContainer.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import currentUser from "$stores/currentUser";
	import { getGAUserContent, getUserContent } from "$stores/user-view";
	import { NDKEvent, NDKUser } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";

    export let user: NDKUser;

    const userContent = getUserContent();
    const userGAContent = getGAUserContent();

    const allContent = derived([userContent, userGAContent], ([$userContent, $userGAContent]) => {
        const ret = [...$userContent, ...$userGAContent]
            .sort((a, b) => b.created_at! - a.created_at!);
            
        return ret.filter((e: NDKEvent) => !requiredTiersFor(e).includes('Free'));
    });
</script>

<PageTitle title="Backstage" />

{#if $allContent.length === 0 && user.pubkey === $currentUser?.pubkey}
    <StylishContainer class="p-6" border={1}>
        You don't currently have any backstage content.
    </StylishContainer>
    <div class="divider my-0"></div>
{/if}

<div class="discussion-wrapper">
    <StoreFeed feed={allContent} />
</div>