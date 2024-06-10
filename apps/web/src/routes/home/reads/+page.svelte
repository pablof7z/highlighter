<script lang="ts">
	import { NDKArticle, NDKKind, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { layoutMode } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { wot, wotFiltered, wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
	import { filterArticle } from "$utils/article-filter";

    $layoutMode = "full-width";

    const articles = $ndk.storeSubscribe(
        { kinds: [NDKKind.Article], limit: 200 },
        { subId: 'home-articles', cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY },
        NDKArticle
    );

    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;

    const filteredArticles = derived(wotF, ($wotF) => {
        return filterArticle(wotF);
    });

    onDestroy(() => {
        articles.unsubscribe();
    });
</script>

<div class="mx-auto w-full">
    <StoreGrid feed={filteredArticles} renderLimit={1} />
</div>