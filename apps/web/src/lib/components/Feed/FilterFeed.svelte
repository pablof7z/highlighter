<script lang="ts">
	import { NDKFilter, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import { ndk } from "@kind0/ui-common";
	import { onDestroy } from "svelte";
	import StoreFeed from "./StoreFeed.svelte";
	import { derived } from "svelte/store";

    export let filters: NDKFilter[];
    export let newPostKind: NDKKind | undefined = undefined;
    export let renderLimit = 10;
    export let newPostTags: NDKTag[] = [];
    export let urlPrefix: string | undefined = undefined;

    export let feed = $ndk.storeSubscribe(filters, { subId: 'feed' });

    let showEventsOlderThan: Date | undefined = undefined;

    feed.onEose(() => {
        showEventsOlderThan = new Date();
    });

    // const sortedFeed = derived(feed, $feed => {
    //     return $feed.sort((a, b) => b.created_at! - a.created_at!);
    // });

    onDestroy(() => { if (filters) feed?.unsubscribe(); });
</script>

<StoreFeed
    feed={feed}
    bind:showEventsOlderThan
    {newPostKind}
    {renderLimit}
    {newPostTags}
    {urlPrefix}
    on:click
/>