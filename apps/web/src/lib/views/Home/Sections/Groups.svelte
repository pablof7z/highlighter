<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
    import * as Card from '$components/Card';
    import * as Groups from '$components/Groups';
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKList, NDKTag } from "@nostr-dev-kit/ndk";
	import { derived, get } from "svelte/store";
	import { groupsList } from "$stores/session";
	import { appMobileView } from '$stores/app';
	import Sidebar from '../Main/Sidebar.svelte';

    const otherGroups = $ndk.storeSubscribe([
        { kinds: [ NDKKind.SimpleGroupList ] }
    ], undefined, NDKList);

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
            .slice(0, 10);
    });
</script>

{#if $appMobileView}
    <Sidebar />
{:else if $selectedGroups.length > 0}
    <HorizontalList class="py-[var(--section-vertical-padding)]" title="Communities" items={$selectedGroups.map(tag => { return {tag, id: tag?.[1] } })} let:item>
        <Groups.Root
            groupId={item.tag[1]}
            relays={item.tag.slice(2)}
            let:group
            let:metadata
            let:tiers
            let:isAdmin
        >
            <Card.Community
                {group}
                {metadata}
                {tiers}
                {isAdmin}
            />
        </Groups.Root>
    </HorizontalList>
{/if}