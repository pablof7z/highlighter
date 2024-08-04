<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
    import * as Card from '$components/Card';
    import * as Groups from '$components/Groups';
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKList, NDKTag } from "@nostr-dev-kit/ndk";
	import { derived, get } from "svelte/store";
	import { groupsList } from "$stores/session";
	import { groupKey } from '$stores/groups';

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
            .slice(0, 10);
    });
</script>

<!-- {#if $groupsList && $groupsList.items.length > 0}
    <Chat.List>
        <Groups.RootList tags={$groupsList.items} let:groupEntry>
            <Chat.Item {groupEntry} />
        </Groups.RootList>
    </Chat.List>
{/if}
 -->
<!-- <div class="my-6" /> -->

{#if $selectedGroups.length > 0}
    <HorizontalList class="py-[var(--section-vertical-padding)]" title="Communities" items={$selectedGroups.map(tag => { return {tag, id: groupKey(tag[1], tag.slice(2))} })} let:item>
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