<script lang="ts">
	import { NDKArticle, NDKFilter, NDKKind, NDKList, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable } from "svelte/store";
	import { filterArticles } from "$utils/article-filter";
	import { page } from "$app/stores";
    import { addHistory } from "$stores/history.js";
    import * as Feed from "$components/Feed";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { getSaveForLaterListForEvent } from "$actions/Events/save-for-later";
	import Button from "$components/ui/button/button.svelte";
	import { BookmarkSimple } from "phosphor-svelte";
	import { urlFromEvent } from "$utils/url";
	import Checkbox from "$components/Forms/Checkbox.svelte";

    onMount(() => {
        addHistory({ title: "Reads", url: $page.url.toString() })
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

    let wotFilter = true;

    let store: Readable<NDKArticle[]>;

    $: {
        let s: Readable<NDKArticle[]>;

        if (wotFilter) {
            s = wotFilteredStore(articles) as Readable<NDKArticle[]>;
        } else {
            s = articles;
        }

        store = filterArticles(s);
    }

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


<div class="flex flex-row items-end border rounded p-4 mb-4">
    <Checkbox
    type="switch"
        bind:value={wotFilter}
    >
        WOT
    </Checkbox>

</div>

{#key wotFilter}
    <Feed.Articles
        {store}
    />
{/key}