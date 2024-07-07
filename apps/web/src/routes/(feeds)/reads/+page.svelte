<script lang="ts">
	import { NDKArticle, NDKFilter, NDKKind, NDKRelaySet, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { layout, layoutMode } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { wot, wotFiltered, wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
	import { filterArticle } from "$utils/article-filter";
	import { page } from "$app/stores";
	import PageTitle from "$components/PageElements/PageTitle.svelte";
	import Section from "$components/Layout/Headers/Section.svelte";

    $layout.header = {
        component: Section,
        props: {
            title: "Reads",
            backUrl: "/",
            // options: [
            //     { name: "Recent", value: "recent" },
            // ]
        }
    }

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

    const filteredArticles = derived(wotF, ($wotF) => {
        return filterArticle(wotF);
    });

    onDestroy(() => {
        articles.unsubscribe();
    });
</script>

<PageTitle title="Reads" />

<div class="mx-auto w-full">
    <StoreGrid feed={filteredArticles} renderLimit={1} />
</div>