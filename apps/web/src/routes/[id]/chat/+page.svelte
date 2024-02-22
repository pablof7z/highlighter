<script lang="ts">
	import MainWrapper from "$components/Page/MainWrapper.svelte";
    import ChatInput from "$components/Chat/Input.svelte";
	import { page } from "$app/stores";
	import { NDKKind, NDKRelay, NDKRelaySet, type NDKTag } from "@nostr-dev-kit/ndk";
	import { ndk } from "@kind0/ui-common";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { onDestroy, onMount } from "svelte";
	import { derived } from "svelte/store";
	import ChatBubble from "$components/Chat/ChatBubble.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import type { UserProfileType } from '../../../app';
	import { pageHeader } from '$stores/layout';
	import { creatorRelayPubkey } from "$utils/const";
	import ChatNewMember from "$components/Chat/ChatNewMember.svelte";
	import { lastSeenGroupTimestamp } from "$stores/notifications";

    let { user } = $page.data;
    let userProfile: UserProfileType;

    const tags: NDKTag[] = [
        [ "h", user.pubkey ]
    ]

    const relaySet = getDefaultRelaySet();

    const events = $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupAdminAddUser ], "#h": [user.pubkey], authors: [creatorRelayPubkey] },
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

    const allRelays = Array.from($ndk.pool.relays.values());
    for (const relay of allRelays) {
        const relaySet = new NDKRelaySet(new Set([relay]), $ndk);

    }

    onMount(() => {
        $lastSeenGroupTimestamp ??= {};
        $lastSeenGroupTimestamp[user.pubkey] ??= Math.floor(Date.now() / 1000);
    })
</script>

<UserProfile {user} bind:userProfile />

<MainWrapper
    class="!min-h-0 min-h-[calc(100vh-4rem)] flex flex-col"
    marginClass="w-full"
>
    <div class="flex flex-col h-full grow justify-end h-full gap-6 overflow-y-auto scrollable-content">
        <div class="flex flex-col justify-end gap-6">
            {#each $sortedEvents as event (event.id)}
                {#if event.kind === NDKKind.GroupAdminAddUser}
                    <ChatNewMember {event} />
                {:else}
                    <ChatBubble {event} />
                {/if}
            {/each}
        </div>

        <ChatInput {tags} />
    </div>

</MainWrapper>
