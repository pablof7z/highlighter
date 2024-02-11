<script lang="ts">
	import MainWrapper from "$components/Page/MainWrapper.svelte";
    import ChatInput from "$components/Chat/Input.svelte";
	import { page } from "$app/stores";
	import { NDKKind, type NDKTag } from "@nostr-dev-kit/ndk";
	import { ndk } from "@kind0/ui-common";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import type { UserProfileType } from '../../../app';
	import { pageHeader } from '$stores/layout';

    let { user } = $page.data;
    let userProfile: UserProfileType;

    const tags: NDKTag[] = [
        [ "h", user.pubkey ]
    ]

    const relaySet = getDefaultRelaySet();

    const events = $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupChat], "#h": [user.pubkey] },
        { kinds: [NDKKind.Article, NDKKind.HorizontalVideo], "#h": [user.pubkey] },
    ], { relaySet, groupable: false });

    onDestroy(() => {
        events.unsubscribe();
    });

    const sortedEvents = derived(events, $events => {
        const sorted = Array.from($events.values()).sort((a, b) => a.created_at! - b.created_at!);
        return sorted;
    });

    $: $pageHeader.title = userProfile?.displayName;
</script>

<UserProfile {user} bind:userProfile />

<MainWrapper
    class="!min-h-0 h-[calc(100vh-4rem)] flex flex-col"
    marginClass="max-w-5xl mx-auto"
>
    <div class="flex flex-col grow justify-end gap-6 overflow-y-auto scrollable-content">
        <div class="flex flex-col justify-end gap-6">
        {#each $sortedEvents as event (event.id)}
            <ChatBubble {event} />
        {/each}
        </div>

        <ChatInput {tags} />
    </div>

</MainWrapper>
