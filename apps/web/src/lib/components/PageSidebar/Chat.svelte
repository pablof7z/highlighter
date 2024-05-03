<script lang="ts">
	import type { Hexpubkey, NDKFilter } from '@nostr-dev-kit/ndk';
	import { ndk } from '@kind0/ui-common';
	import { NDKEvent, NDKKind, NDKSubscriptionCacheUsage, NDKUser } from '@nostr-dev-kit/ndk';
    import { userFollows } from "$stores/session";
	import ChatItem from './ChatItem.svelte';
	import { derived, type Readable } from 'svelte/store';
	import { onDestroy } from 'svelte';
	import currentUser from '$stores/currentUser';

    export let activeUser: NDKUser | undefined = undefined;

    const allPubkeys = Array.from($userFollows);
    // make sure my own pubkey is included
    if ($currentUser?.pubkey && !allPubkeys.includes($currentUser.pubkey)) {
        allPubkeys.push($currentUser.pubkey);
    }

    const filters: NDKFilter[] = [ { kinds: [NDKKind.GroupMembers], "#d": allPubkeys } ]

    if ($currentUser) {
        filters.push({ kinds: [NDKKind.GroupMembers], "#p": [$currentUser.pubkey] });
    }

    const followsWithCommunities = $ndk.storeSubscribe(filters, { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY })

    let selectedCommunity: NDKEvent | undefined;

    let communitiesTheUserDoesntBelongTo: Readable<NDKEvent[]>;
    let communitiesTheUserBelongsTo: Readable<NDKEvent[]>;

    $: {
        communitiesTheUserBelongsTo = derived(followsWithCommunities, $followsWithCommunities => {
            const dTag = new Map<Hexpubkey, NDKEvent>();

            for (const event of $followsWithCommunities) {
                const d = event.dTag;
                if (!d) continue;
                if (!event.tags.some(t => t[0] === 'p' && t[1] === $currentUser?.pubkey)) continue;

                const v = dTag.get(d);
                if (v && event.created_at! <= v.created_at!) continue;

                dTag.set(d, event);
            }

            return Array.from(dTag.values());
        });
        
        communitiesTheUserDoesntBelongTo = derived(followsWithCommunities, $followsWithCommunities => {
            const dTag = new Map<Hexpubkey, NDKEvent>();

            selectedCommunity = $followsWithCommunities.find(event => event.dTag === activeUser?.pubkey);

            for (const event of $followsWithCommunities) {
                const d = event.dTag;
                if (!d) continue;

                const v = dTag.get(d);
                if (v && event.created_at! <= v.created_at!) continue;

                dTag.set(d, event);
            }

            return Array.from(dTag.values());
        });
    }

    onDestroy(() => {
        followsWithCommunities?.unsubscribe();
    });
</script>

<div class="h-full overflow-y-auto flex flex-col self-stretch sticky scrollbar-hide overscroll-contain">
    {#if selectedCommunity}
        {#key selectedCommunity}
            <ChatItem
                groupMembersEvent={selectedCommunity}
                active={true}
            />
        {/key}
    {/if}

    <!-- {#if $groupsList}
        {#each $groupsList.getItems("group") as group}
            {group}
        {/each}
        there
    {/if} -->

    {#each $communitiesTheUserBelongsTo as groupMembersEvent, i (groupMembersEvent.dTag)}
        {#if groupMembersEvent.dTag !== activeUser?.pubkey}
            <ChatItem
                {groupMembersEvent}
                class="{i % 2 === 0 ? 'bg-base-200/80' : 'bg-base-100'}"
            />
        {/if}
    {/each}
</div>