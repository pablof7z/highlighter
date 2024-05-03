<script lang="ts">
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
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

{#if $allContent.length === 0 && user.pubkey === $currentUser?.pubkey}
    <StylishContainer class="p-6" border={1}>
        You don't currently have any backstage content.
    </StylishContainer>
    <div class="divider my-0"></div>
{/if}

<div class="bg-white/10 flex flex-col gap-6 p-6 grow rounded-box">
    <div class="flex flex-row justify-between items-center">
        <span class="text-sm">
            Backstage Content
        </span>
    </div>

    <div class="flex flex-col grow overflow-y-auto overflow-x-clip">
        <StoreFeed feed={allContent} />
    </div>
</div>