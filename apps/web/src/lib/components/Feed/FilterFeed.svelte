<script lang="ts">
	import { NDKFilter, NDKKind, NDKRelaySet, NDKTag } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk.js";
	import { onDestroy } from "svelte";
	import StoreFeed from "./StoreFeed.svelte";

    export let filters: NDKFilter[];
    export let renderLimit = 10;
    export let urlPrefix: string | undefined = undefined;
    export let relaySet: NDKRelaySet | undefined = undefined;

    export let feed = $ndk.storeSubscribe(filters, { subId: 'feed', relaySet });
    
    export let showEventsOlderThan: Date | undefined = undefined;

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
    {renderLimit}
    {urlPrefix}
    on:click
/>