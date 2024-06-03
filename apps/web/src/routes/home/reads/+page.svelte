<script lang="ts">
	import { NDKArticle, NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { layoutMode } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { wot, wotFiltered, wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
	import { filterArticle } from "$utils/article-filter";

    $layoutMode = "single-column-focused";

    const articles = $ndk.storeSubscribe(
        { kinds: [NDKKind.Article], limit: 50 },
        { subId: 'home-articles' },
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


<StoreFeed feed={filteredArticles} renderLimit={50} />