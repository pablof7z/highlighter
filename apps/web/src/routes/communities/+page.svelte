<script lang="ts">
	import NewGroupModal from '$modals/NewGroupModal.svelte';
	import PageTitle from "$components/PageElements/PageTitle.svelte";
    import { layoutMode, pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { groupsList, userFollows } from "$stores/session";
	import { openModal } from "$utils/modal";
	import { NDKKind, NDKList, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { Button } from '$components/ui/button';
	import { derived } from 'svelte/store';
    import * as Chat from "$components/Chat";
	import { Plus } from 'phosphor-svelte';
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';

    $layoutMode = "single-column-focused";
    
    $pageHeader = null;

    onDestroy(() => {
        $pageHeader = null;
    });

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

<div class="py-2 border-y border-border responsive-padding">
    <HorizontalOptionsList options={[
        { name: "Communities", href: "/communities", buttonProps: { variant: 'accent' } },
        { name: "Articles", href: "/reads" },
        { name: "Videos", href: "/videos" },
    ]} />
</div>

{#if groupsList && $groupsList}
    <Chat.List>
        {#each $groupsList.items as item (item)}
            <Chat.Item tag={item} />
        {/each}
    </Chat.List>
{/if}

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