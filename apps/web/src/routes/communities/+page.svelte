<script lang="ts">
	import NewGroupModal from '$modals/NewGroupModal.svelte';
    import { layout, layoutMode, pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { groupsList, userFollows } from "$stores/session";
	import { openModal } from "$utils/modal";
	import { NDKKind, NDKList, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import { Button } from '$components/ui/button';
	import { derived } from 'svelte/store';
    import * as Chat from "$components/Chat";
	import { Plus } from 'phosphor-svelte';
	import Section from '$components/Layout/Headers/Section.svelte';
	import { addHistory } from '$stores/history';

    addHistory({ title: "Communities", url: "/communities" });

    const relaySet = NDKRelaySet.fromRelayUrls(["wss://groups.fiatjaf.com"], $ndk);

    const groups = $ndk.storeSubscribe(
        { kinds: [NDKKind.GroupMetadata]}, {
            relaySet
        }
    );

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
</script>

{#if groupsList && $groupsList}
    <Chat.List>
        {#each $groupsList.items as item (item)}
            <Chat.Item tag={item} />
        {/each}
    </Chat.List>
{/if}

{#each $groups as group}
    <Chat.Item tag={["group", group.dTag, group.relay.url]} />
{/each}

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