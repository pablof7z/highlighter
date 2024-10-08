<script lang="ts">
	import NewGroupModal from '$modals/NewGroupModal.svelte';
    import { layout } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import { NDKEvent, NDKKind, NDKList, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import { Button } from '$components/ui/button';
	import { derived, get } from 'svelte/store';
    import * as Groups from "$components/Groups";
	import { Plus } from 'phosphor-svelte';
	import { addHistory } from '$stores/history';
	import { defaultRelays } from '$utils/const';

    addHistory({ title: "Communities", url: "/communities" });

    $layout.back = { url: "/" };
    $layout.title = "🏡 Communities";
    $layout.iconUrl = undefined;
    $layout.options = undefined;
    $layout.sidebar = false;
    $layout.fullWidth = false;
    $layout.event = undefined;

    const relaySet = NDKRelaySet.fromRelayUrls(defaultRelays, $ndk);
    const allGroups = $ndk.storeSubscribe({ kinds: [NDKKind.GroupMetadata] }, { groupable: false, closeOnEose: true, relaySet });

    const groupListsFromFollows = $ndk.storeSubscribe(
        { kinds: [NDKKind.SimpleGroupList], limit: 300 },
        { groupable: false, closeOnEose: true }, NDKList
    )

    const unifiedGroupLists = derived([
        groupListsFromFollows,
        allGroups
    ], ([$groupListsFromFollows, $allGroups]) => {
        const unified: Record<string, number> = {};

        $allGroups.forEach(group => {
            const tag = ["group", group.tagValue('d'), defaultRelays[0]]
            const key = JSON.stringify(tag);
            unified[key] = 1;
            console.log('pushing', key);
        });
        
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
            .slice(0, 50)
            .map(k => JSON.parse(k));
    })
</script>

<Groups.RootList tags={$unifiedGroupLists} let:group>
    <Groups.ListItem {group} />
</Groups.RootList>

<!-- {#if Object.keys($groups).length > 0}
    <Chat.List>
        {#each Object.entries($groups) as [id, groupEntry] (id)}
            {#if groupEntry}
                <Chat.Item {groupEntry} />
            {:else}
                huh?
            {/if}
        {/each}
    </Chat.List>
{/if} -->

<!-- {#if $unifiedGroupLists}
    <Chat.List>
        <Groups.RootList tags={$unifiedGroupLists} let:groupEntry>
            <Chat.Item {groupEntry} />
        </Groups.RootList>
    </Chat.List>
{/if} -->

<div class="responsive-padding">
    <Button variant="outline" class="w-full mt-12 h-auto rounded-lg p-6 flex flex-col items-center" on:click={() => openModal(NewGroupModal)}>
        <div class="bg-secondary rounded-full p-3 flex items-center justify-center mb-4">
            <Plus size={32} />
        </div>
        <p class="text-center text-lg font-medium">Create New Community</p>
    </Button>
</div>