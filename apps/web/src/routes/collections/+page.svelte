<script lang="ts">
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
import NewPost from "$components/Feed/NewPost/NewPost.svelte";
    import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { userFollows } from "$stores/session";
    import { ndk } from "@kind0/ui-common";
    import { NDKEvent, NDKKind, NDKRelay, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { onDestroy, onMount } from "svelte";
	import { derived } from "svelte/store";

    const pp = NDKRelaySet.fromRelayUrls(['wss://purplepag.es'], $ndk);
    
    let collections: NDKEventStore<NDKEvent>;
    
    onMount(() => {
        collections = $ndk.storeSubscribe([
            { kinds: [1111 as number], authors: ["fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52"]}
        ], { relaySet: pp, subId: 'collections' });

    })

    onDestroy(() => {
        collections.unsubscribe();
    })

    // const c1 = $ndk.subscribe([
    //     { kinds: [1111 as number], authors: ["fa984bd7dbb282f07e16e7ae87b26a2a7b9b90b7246a44771f0cf5ae58018f52"]}
    // ], undefined, pp);
    // c1.on("event", (e: NDKEvent) => {
    //     console.log('received on c1', e.rawEvent());
    //     events.push(e);
    //     events = events;
    // });

    let events = [];

    // const collections = $ndk.storeSubscribe([
    //     { kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet], limit: 10, authors: Array.from($userFollows) }
    // ]);

    // const sortedCollections = derived(collections, $collections => {
    //     const sorted = Array.from($collections.values()).sort((a, b) => a.created_at! + b.created_at!);
    //     return sorted;
    // });

    let creating = false;
    
    function create() {
        creating = true;
        const ran = Math.random();
        const e = new NDKEvent($ndk, { kind: 1111, content: ran.toString() });
        e.publish(pp);
        creating = false;
    }
    
</script>

{#if collections}
    <button class="button" disabled={creating} on:click={create}>Create</button>

    events = {$collections.length}

    {#each $collections as e (e.id)}
        <p>{e.id} {e.onRelays.length} ({e.publishStatus})</p>

        <FilterFeed filters={[
            { kinds: [9735], "#P": [e.pubkey], ...e.filter()}
        ]} />
    {/each}



    <!-- <StoreFeed feed={sortedCollections} /> -->
{/if}