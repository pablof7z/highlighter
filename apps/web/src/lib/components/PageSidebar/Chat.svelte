<script lang="ts">
	import type { Hexpubkey } from '@nostr-dev-kit/ndk';
	import { ndk } from '@kind0/ui-common';
	import { NDKEvent, NDKKind, NDKUser } from '@nostr-dev-kit/ndk';
	import PageSidebar from "$components/PageSidebar.svelte";
    import { userFollows } from "$stores/session";
	import ChatItem from './ChatItem.svelte';
	import { event } from '$stores/post-editor';
	import { derived, type Readable } from 'svelte/store';

    export let activeUser: NDKUser | undefined = undefined;

    const followsWithCommunities = $ndk.storeSubscribe([
        { kinds: [NDKKind.GroupMembers], "#d": Array.from($userFollows) }
    ])

    let selectedCommunity: NDKEvent | undefined;

    let nonSelectedCommunities: Readable<NDKEvent[]>;

    $: if (activeUser) {
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
</script>

<PageSidebar title="Chat">
    <div class="h-full overflow-y-auto flex flex-col self-stretch sticky scrollbar-hide overscroll-contain">
        {#if selectedCommunity}
            {#key selectedCommunity}
                <ChatItem
                    groupMembersEvent={selectedCommunity}
                    user={$ndk.getUser({pubkey: selectedCommunity.dTag})}
                    active={true}
                />
            {/key}
        {/if}

        {#each $nonSelectedCommunities as groupMembersEvent, i (groupMembersEvent.dTag)}
            {#if groupMembersEvent.dTag !== activeUser?.pubkey}
                <ChatItem
                    {groupMembersEvent}
                    user={$ndk.getUser({pubkey: event.dTag})}
                    class="{i % 2 === 0 ? 'bg-base-200/80' : 'bg-base-100'}"
                />
            {/if}
        {/each}
    </div>
</PageSidebar>
