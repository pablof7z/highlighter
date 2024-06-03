<script lang="ts">
	import { NDKArticle, NDKKind } from "@nostr-dev-kit/ndk";
	import { layoutMode } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { derived } from "svelte/store";
	import { filterArticle } from "$utils/article-filter";

    $layoutMode = "single-column-focused";

    const articles = $ndk.storeSubscribe(
        { kinds: [NDKKind.HorizontalVideo], limit: 50 },
        { subId: 'home-articles' },
        NDKArticle
    );

    const filteredArticles = derived(wotFilteredStore(articles), ($articles) => {
        return filterArticle(articles);
    });

    onDestroy(() => {
        articles.unsubscribe();
    });
</script>

<StoreFeed feed={filteredArticles} renderLimit={50} />