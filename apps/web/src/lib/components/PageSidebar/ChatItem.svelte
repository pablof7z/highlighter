<script lang="ts">
	import { CaretRight, Lock } from 'phosphor-svelte';
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
    import UserProfile from "$components/User/UserProfile.svelte";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { ndk } from "@kind0/ui-common";
    import { NDKKind, type NDKFilter, type NDKTag, NDKEvent } from "@nostr-dev-kit/ndk";
    import { user as currentUser } from "@kind0/ui-common";
	import { onDestroy } from "svelte";
	import { lastSeenGroupTimestamp } from "$stores/notifications";
	import { mainContentKinds } from "$utils/event";
	import { derived } from 'svelte/store';
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';

    export let groupMembersEvent: NDKEvent;
    export let active = false;

    const user = $ndk.getUser({pubkey: groupMembersEvent.dTag});

    let lastSeenTime = ($lastSeenGroupTimestamp??{})[user.pubkey];

    const lastMessagesFilter: NDKFilter = { kinds: [NDKKind.GroupChat, ...mainContentKinds], "#h": [user.pubkey] }
    if (lastSeenTime) lastMessagesFilter.since = lastSeenTime;

    const messagesSinceLastRead = $ndk.storeSubscribe(
        lastMessagesFilter,
        { groupable: true, groupableDelay: 500, groupableDelayType: "at-least", relaySet: getDefaultRelaySet() }
    );

    onDestroy(() => {
        messagesSinceLastRead.unsubscribe()
    });

    let memberCount: number;
    let isMember: boolean;

    $: memberCount = groupMembersEvent.getMatchingTags("p").length;
    $: isMember = groupMembersEvent.tags.some((t: NDKTag) => t[0] === "p" && t[1] === $currentUser.pubkey);

    const lastMessage = derived(messagesSinceLastRead, $messagesSinceLastRead => {
        const count = $messagesSinceLastRead.length;
        return $messagesSinceLastRead.sort((a, b) => a.created_at! - b.created_at!)?.[count - 1];
    });
</script>

<UserProfile {user} let:userProfile let:fetching let:authorUrl>
    {#key authorUrl}
        <a
            href={`${authorUrl}/chat`} class="flex flex-row gap-6 p-3 items-center {$$props.class??""}"
            class:list-item--active={active}
        >
            <div class="grow shrink basis-0 flex-col justify-start items-start gap-2 inline-flex max-h-36 overflow-clip">
                <div class="self-stretch text-white text-base font-medium leading-relaxed max-h-12 overflow-clip">
                    <AvatarWithName {user} {userProfile} {fetching} class="max-w-[15rem] truncate">
                        {#if $lastMessage}
                            <EventContent ndk={$ndk} event={$lastMessage} class="text-sm text-neutral-500 truncate" />
                        {:else if memberCount}
                            <span class="text-sm text-neutral-500 truncate">
                                {memberCount} members
                            </span>
                        {/if}
                    </AvatarWithName>
                </div>
            </div>

            {#if $messagesSinceLastRead.length > 0}
                <div class="flex items-center justify-center w-8 h-8 shrink rounded-full bg-base-200">
                    {$messagesSinceLastRead.length}
                </div>
            {:else}
                <div class="flex items-center justify-center">
                    {#if isMember}
                        <CaretRight size="24" />
                    {:else}
                        <Lock size="24" />
                    {/if}
                </div>
            {/if}
        </a>
    {/key}
</UserProfile>
