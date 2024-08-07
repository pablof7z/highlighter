<script lang="ts">
    import * as Groups from '$components/Groups';
    import * as Chat from '$components/Chat';
    import { groupsList } from "$stores/session";
	import { NDKKind, NDKList, NDKRelaySet, NDKSubscriptionCacheUsage, NDKTag } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';
	import { derived } from 'svelte/store';
	import { groupKey } from '$stores/groups';

    const relaySet = NDKRelaySet.fromRelayUrls(['wss://groups.0xchat.com', 'wss://groups.fiatjaf.com'], $ndk);
    const otherGroups = $ndk.storeSubscribe([
        { kinds: [ NDKKind.SimpleGroupList ] }
    ], {groupable: false, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY}, NDKList);

    const selectedGroups = derived([ groupsList, otherGroups ], ([ $groupsList, $otherGroups ]) => {
        const tags = new Map<string, NDKTag>();
        const groupMap = new Map<string, number>();

        let usersGroupIds: Set<string>;
            if ($groupsList) {
                usersGroupIds = new Set($groupsList.items.map(item => item[1]));
            } else { usersGroupIds = new Set(); }

        for (const list of $otherGroups) {
            for (const item of list.items) {
                const key = groupKey(item[1], item.slice(2));
                const groupId = item[1];

                // skip if the user already follows this group
                if (usersGroupIds.has(groupId)) continue;
                
                tags.set(key, item);
                groupMap.set(key, (groupMap.get(key) ?? 0) + 1);
            }
        }

        // sort by count
        return Array.from(groupMap.entries())
            .sort((a, b) => b[1] - a[1])
            .map(([key, count]) => tags.get(key))
            .slice(0, 1000) as NDKTag[];
    });
</script>

{#if $groupsList && $groupsList.items.length > 0}
    <div class="divide-y divide-border border-y">
        <Groups.RootList tags={$groupsList.items} let:groupEntry>
            <Chat.Item {groupEntry} />
        </Groups.RootList>
    </div>
{/if}

{#if $selectedGroups && $selectedGroups.length > 0}
    <div class="divide-y divide-border border-y">
        <Groups.RootList tags={$selectedGroups} let:groupEntry>
            <Chat.Item {groupEntry} />
        </Groups.RootList>
    </div>
{/if}