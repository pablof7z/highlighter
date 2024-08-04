<script lang="ts">
	import { NDKArticle, NDKFilter, NDKKind, NDKRelaySet, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { layout, layoutMode } from "$stores/layout";
	import { onDestroy, onMount } from "svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { wot, wotFiltered, wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
	import { filterArticles } from "$utils/article-filter";
	import { page } from "$app/stores";
    import { addHistory } from "$stores/history.js";
    import * as Feed from "$components/Feed";
	import { Fire } from "phosphor-svelte";

    $layout.title = "Reads";
    $layout.back = { url: "/" };
    $layout.fullWidth = false;
    $layout.sidebar = false;

    $layout.navigation = [
        { value: "", name: "Newest" },
        { name: "🔥 Hot" },
        { name: "⚡️ Zapped" },
    ]
    $layout.activeOption = $layout.navigation[0];

    onMount(() => {
        addHistory({ title: "Articles", url: $page.url.toString() })
    })

    const relays = $page.url.searchParams.get('relays')?.split(',');
    let relaySet: NDKRelaySet | undefined;
    let filters: NDKFilter[] = [{ kinds: [NDKKind.Article], limit: 200 }];

    if (relays && relays.length > 0) {
        relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);
        filters.push({ limit: 500 })
    }

    const articles = $ndk.storeSubscribe(
        filters,
        { subId: 'home-articles', relaySet },
        NDKArticle
    );

    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;

    const filteredArticles = filterArticles(wotF);

    onDestroy(() => {
        articles.unsubscribe();
    });
</script>

<Feed.Articles
    store={filteredArticles}
/>