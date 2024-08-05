<script lang="ts">
    import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { wotFiltered } from "$stores/wot";
    import { ndk } from "$stores/ndk.js";
    import { NDKKind } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";

    onDestroy(() => {
        collections.unsubscribe();
    })

    let events = [];

    const collections = $ndk.storeSubscribe([
        { kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet], limit: 10 }
    ]);

    const sortedCollections = derived(collections, $collections => {
        const sorted = Array.from($collections.values()).sort((a, b) => a.created_at! + b.created_at!);
        return wotFiltered(sorted);
    });
</script>

{#if collections}
    <StoreFeed feed={sortedCollections} />
{/if}