<script lang="ts">
    import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import { userFollows } from "$stores/session";
	import { wotFiltered } from "$stores/wot";
    import { ndk } from "@kind0/ui-common";
    import { NDKEvent, NDKKind, NDKRelay, NDKRelaySet } from "@nostr-dev-kit/ndk";
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

<PageTitle title="Collections" />

{#if collections}
    <StoreFeed feed={sortedCollections} />
{/if}