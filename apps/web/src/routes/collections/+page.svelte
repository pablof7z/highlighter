<script lang="ts">
    import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { userFollows } from "$stores/session";
    import { ndk } from "@kind0/ui-common";
    import { NDKKind } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";

    const collections = $ndk.storeSubscribe([
        { kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet], limit: 10, authors: Array.from($userFollows) }
    ]);

    const sortedCollections = derived(collections, $collections => {
        const sorted = Array.from($collections.values()).sort((a, b) => a.created_at! + b.created_at!);
        return sorted;
    });
</script>

<StoreFeed feed={sortedCollections} />