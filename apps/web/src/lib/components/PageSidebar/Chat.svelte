<script lang="ts">
	import type { Hexpubkey, NDKFilter } from '@nostr-dev-kit/ndk';
	import { ndk, user } from '@kind0/ui-common';
	import { NDKEvent, NDKKind, NDKSubscriptionCacheUsage, NDKUser } from '@nostr-dev-kit/ndk';
	import PageSidebar from "$components/PageSidebar.svelte";
    import { userFollows } from "$stores/session";
	import ChatItem from './ChatItem.svelte';
	import { derived, type Readable } from 'svelte/store';
	import { getDefaultRelaySet } from '$utils/ndk';
	import { onDestroy } from 'svelte';

    export let activeUser: NDKUser | undefined = undefined;

    const allPubkeys = Array.from($userFollows);
    // make sure my own pubkey is included
    if ($user?.pubkey && !allPubkeys.includes($user.pubkey)) {
        allPubkeys.push($user.pubkey);
    }

    const filters: NDKFilter[] = [ { kinds: [NDKKind.GroupMembers], "#d": allPubkeys } ]

    if ($user) {
        filters.push({ kinds: [NDKKind.GroupMembers], "#p": [$user.pubkey] });
    }

    const followsWithCommunities = $ndk.storeSubscribe(filters, { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY, relaySet: getDefaultRelaySet() })

    let selectedCommunity: NDKEvent | undefined;

    let nonSelectedCommunities: Readable<NDKEvent[]>;

    $: {
        nonSelectedCommunities = derived(followsWithCommunities, $followsWithCommunities => {
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

<PageSidebar title="Chat" innerClass="!px-0 !gap-0">
    <div class="h-full overflow-y-auto flex flex-col self-stretch sticky scrollbar-hide overscroll-contain">
        {#if selectedCommunity}
            {#key selectedCommunity}
                <ChatItem
                    groupMembersEvent={selectedCommunity}
                    active={true}
                />
            {/key}
        {/if}

        {#each $nonSelectedCommunities as groupMembersEvent, i (groupMembersEvent.dTag)}
            {#if groupMembersEvent.dTag !== activeUser?.pubkey}
                <ChatItem
                    {groupMembersEvent}
                    class="{i % 2 === 0 ? 'bg-base-200/80' : 'bg-base-100'}"
                />
            {/if}
        {/each}
    </div>
</PageSidebar>
