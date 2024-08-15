<script lang="ts">
    import * as Groups from '$components/Groups';
    import { groupsList, userFollows } from "$stores/session";
	import { NDKFilter, NDKKind, NDKList, NDKRelaySet, NDKSimpleGroupMemberList, NDKSubscriptionCacheUsage, NDKTag } from '@nostr-dev-kit/ndk';
	import { ndk } from '$stores/ndk';
	import { derived } from 'svelte/store';
	import currentUser from '$stores/currentUser';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';


    const filter: NDKFilter = { kinds: [ NDKKind.SimpleGroupList ] };

    if ($currentUser) {
        filter.authors = Array.from($userFollows);
    } else {
        filter.authors = ["fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52"]
    }

    let groupsUserAdmins: NDKEventStore<NDKSimpleGroupMemberList>;
    $: if (!groupsUserAdmins && $currentUser) {
        groupsUserAdmins = $ndk.storeSubscribe([
            { kinds: [ NDKKind.GroupMembers], "#p": [$currentUser.pubkey] }
        ])
    }

    const otherGroups = $ndk.storeSubscribe(filter, {groupable: false, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY}, NDKList);

    const selectedGroups = derived([ groupsList, otherGroups ], ([ $groupsList, $otherGroups ]) => {
        const tags = new Map<string, NDKTag>();
        const groupMap = new Map<string, number>();

        let usersGroupIds: Set<string>;
            if ($groupsList) {
                usersGroupIds = new Set($groupsList.items.map(item => item[1]));
            } else { usersGroupIds = new Set(); }

        for (const list of $otherGroups) {
            for (const item of list.items) {
                const groupId = item[1];

                // skip if the user already follows this group
                if (usersGroupIds.has(groupId)) continue;
                
                tags.set(groupId, item);
                groupMap.set(groupId, (groupMap.get(groupId) ?? 0) + 1);
            }
        }

        // sort by count
        return Array.from(groupMap.entries())
            .sort((a, b) => b[1] - a[1])
            .map(([key, count]) => tags.get(key))
            .slice(0, 1000) as NDKTag[];
    });
</script>
hi
{#if $groupsList && $groupsList.items.length > 0}
    <div class="divide-y divide-border border-y">
        <Groups.RootList tags={$groupsList.items} let:group>
            <Groups.ListItem {group} />
        </Groups.RootList>
    </div>
{/if}

{#if $selectedGroups && $selectedGroups.length > 0}
    <div class="divide-y divide-border border-y">
        <Groups.RootList tags={$selectedGroups} let:group>
            <Groups.ListItem {group} />
        </Groups.RootList>
    </div>
{/if}

