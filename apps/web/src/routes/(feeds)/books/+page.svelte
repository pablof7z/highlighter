<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { NDKArticle, NDKFilter, NDKKind, NDKRelaySet, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { layout } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
	import { filterArticle } from "$utils/article-filter";
	import { page } from "$app/stores";
    import * as Card from '$components/Card';
	import Section from "$components/Layout/Headers/Section.svelte";

    $layout.header = {
        component: Section,
        props: {
            title: "Books",
            backUrl: "/",
            // options: [
            //     { name: "Recent", value: "recent" },
            // ]
        }
    }

    const relays = $page.url.searchParams.get('relays')?.split(',');
    let relaySet: NDKRelaySet | undefined = NDKRelaySet.fromRelayUrls(["wss://thecitadel.nostr1.com"], $ndk);
    let filters: NDKFilter[] = [{ kinds: [30040], limit: 200 }];

    if (relays && relays.length > 0) {
        relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);
        filters.push({ limit: 500 })
    }

    const books = $ndk.storeSubscribe(
        filters,
        { subId: 'home-books', relaySet },
        NDKArticle
    );

    // const wotF = wotFilteredStore(books) as Readable<NDKArticle[]>;

    // const filteredArticles = derived(wotF, ($wotF) => {
    //     return filterArticle(wotF);
    // });

    onDestroy(() => {
        books.unsubscribe();
    });
</script>

<HorizontalList title="Books" items={$books} let:item>
    <Card.Article article={item} />
</HorizontalList>