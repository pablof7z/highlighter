<script lang="ts">
	import { NDKArticle, NDKFilter, NDKKind, NDKList, NDKRelaySet, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
	import { filterArticles } from "$utils/article-filter";
	import { page } from "$app/stores";
    import { addHistory } from "$stores/history.js";
    import * as Feed from "$components/Feed";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { getSaveForLaterListForEvent } from "$actions/Events/save-for-later";
	import Button from "$components/ui/button/button.svelte";
	import { BookmarkSimple } from "phosphor-svelte";
	import { urlFromEvent } from "$utils/url";

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

    let articles: NDKEventStore<NDKArticle> = $ndk.storeSubscribe(
        filters,
        { subId: 'home-articles', relaySet },
        NDKArticle
    );

    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;

    const filteredArticles = filterArticles(wotF);

    onDestroy(() => {
        articles?.unsubscribe();
    });

    let savedList: NDKList;
    let hasSavedItems = false;
    getSaveForLaterListForEvent(new NDKArticle($ndk))
        .then(list => {
            if (list) {
                hasSavedItems = list.items.length > 0
                savedList = list;
            }
        });
</script>

{#if hasSavedItems}
    <Button variant="outline" href={urlFromEvent(savedList)}>
        <BookmarkSimple size={24} />
        You have saved items
    </Button>
{/if}

<Feed.Articles
    store={filterArticles(articles)}
/>