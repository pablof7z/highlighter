<script lang="ts">
    import { groupsList, userFollows } from "$stores/session";
    import * as Chat from "$components/Chat";
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKList, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";

    const groupListsFromFollows = $ndk.storeSubscribe(
        { kinds: [NDKKind.SimpleGroupList], limit: 300, authors: Array.from($userFollows) },
        { groupable: false, closeOnEose: true }, NDKList
    )

    // const unifiedGroupLists = derived(groupListsFromFollows, $groupListsFromFollows => {
    //     const unified: Record<string, number> = {};
    //     for (const list of $groupListsFromFollows) {
    //         for (const k of list.items) {
    //             const key = JSON.stringify(k);
    //             const current = unified[key] ?? 0;
    //             unified[key] = current + 1;
    //         }
    //     }

    //     // sort and return an array of NDKTag
    //     return Object.entries(unified)
    //         .sort((a, b) => b[1] - a[1])
    //         .map(([k, v]) => k)
    //         .slice(0, 10)
    //         .map(k => JSON.parse(k));
    // })
</script>

hi
<!-- {#if groupsList && $groupsList}
    <Chat.List>
        {#each $groupsList.items as item (item)}
            <Chat.Item tag={item} />
        {/each}
    </Chat.List>
{/if} -->

<!-- <h2>Communities to check out</h2>

{#if $unifiedGroupLists}
    <Chat.List>
        {#each $unifiedGroupLists as item (item)}
            <Chat.Item tag={item} />
        {/each}
    </Chat.List>
{/if} -->