<script lang="ts">
	import NewGroupModal from '$modals/NewGroupModal.svelte';
    import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { groupsList, userFollows } from "$stores/session";
	import { openModal } from "$utils/modal";
	import { NDKKind, NDKList, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import { Button } from '$components/ui/button';
	import { derived, get } from 'svelte/store';
    import * as Chat from "$components/Chat";
	import { Plus } from 'phosphor-svelte';
	import { addHistory } from '$stores/history';
	import { onDestroy } from 'svelte';

    addHistory({ title: "Communities", url: "/communities" });

    $layout.title = "Communities";
    $layout.iconUrl = undefined;

    const relaySet = NDKRelaySet.fromRelayUrls(["wss://groups.0xchat.com/", "wss://groups.fiatjaf.com"], $ndk, true);
    relaySet.addRelay($ndk.pool.getRelay("wss://groups.0xchat.com/", true, true));

    const groups = $ndk.storeSubscribe(
        { kinds: [NDKKind.GroupMetadata]},  {
            relaySet
        }
    );

    onDestroy(() => {
        groups.unsubscribe();
    })

    const groupListsFromFollows = $ndk.storeSubscribe(
        { kinds: [NDKKind.SimpleGroupList], limit: 300, authors: Array.from($userFollows) },
        { groupable: false, closeOnEose: true }, NDKList
    )

    const unifiedGroupLists = derived(groupListsFromFollows, $groupListsFromFollows => {
        const unified: Record<string, number> = {};
        for (const list of $groupListsFromFollows) {
            for (const k of list.items) {
                const key = JSON.stringify(k);
                const current = unified[key] ?? 0;
                unified[key] = current + 1;
            }
        }

        // sort and return an array of NDKTag
        return Object.entries(unified)
            .sort((a, b) => b[1] - a[1])
            .map(([k, v]) => k)
            .slice(0, 10)
            .map(k => JSON.parse(k));
    })

    const groupsNotInList = derived([ groups, groupsList ], ([$groups, $groupsList]) => {
        if (!$groupsList) return $groups;
        const groupListIds = new Set(
            $groupsList.items.map(g => g[1])
        );
        return $groups.filter(g => !groupListIds.has(g.dTag));
    })
</script>

{#if $groupsList && $groupsList.items.length > 0}
    <Chat.List>
        {#each $groupsList.items as group (group[1])}
            <Chat.Item tag={["group", group[1], group[2]]} />
        {/each}
    </Chat.List>
{/if}
<Chat.List>
    {#each $groupsNotInList as group (group.id)}
        <Chat.Item tag={["group", group.dTag, group.relay.url]} />
    {/each}
</Chat.List>

<h2>Communities to check out</h2>

{#if $unifiedGroupLists}
    <Chat.List>
        {#each $unifiedGroupLists as item (item)}
            <Chat.Item tag={item} />
        {/each}
    </Chat.List>
{/if}

<div class="responsive-padding">
    <Button variant="outline" class="w-full mt-12 h-auto rounded-lg p-6 flex flex-col items-center" on:click={() => openModal(NewGroupModal)}>
        <div class="bg-secondary rounded-full p-3 flex items-center justify-center mb-4">
            <Plus size={32} />
        </div>
        <p class="text-center text-lg font-medium">Create New Community</p>
    </Button>
</div>