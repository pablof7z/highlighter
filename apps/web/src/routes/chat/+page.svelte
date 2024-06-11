<script lang="ts">
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import FetchGroupFromTag from "$components/utils/FetchGroupFromTag.svelte";
    import { layoutMode, pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { groupsList, userFollows } from "$stores/session";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable } from "stream";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";

    $layoutMode = "single-column-focused";
    
    $pageHeader = { title: "Community" };

    onDestroy(() => {
        $pageHeader = null;
    });

    const relaySet = getDefaultRelaySet();
    const chatGroups = $ndk.storeSubscribe(
        { kinds: [NDKKind.GroupMetadata], limit: 300, "#d": Array.from($userFollows) },
        { groupable: false, closeOnEose: true }
    )
</script>

<PageTitle title="Communities" />

{#if groupsList && $groupsList}
    {#each $groupsList.items as group}
        <FetchGroupFromTag tag={group}>
            <pre>{JSON.stringify(group.rawEvent())}</pre>
        </FetchGroupFromTag>
    {/each}
{/if}

{#each $chatGroups as group}
    <div>
        {group.tagValue("name")}
    </div>
{/each}

<style>
    h1 {
        @apply text-foreground leading-tight text-[80px];
    }

    h2 {
        @apply text-neutral-500 leading-tight;
    }
</style>