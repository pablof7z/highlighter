<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { chronologically } from "$utils/event";
	import { NDKArticle, NDKEvent, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { derived, writable } from "svelte/store";
    import * as Feed from "$components/Feed";
	import { onDestroy } from "svelte";

    const seenIds = new Set<string>();

    const relaySet = NDKRelaySet.fromRelayUrls([
        'wss://relay.primal.net', 'wss://relay.damus.io', 'wss://relay.highlighter.com'
    ], $ndk);

    const articles = writable<Map<string, { article: NDKArticle | null | undefined, count: number}>>(new Map());

    const highlights = $ndk.storeSubscribe(
        { kinds: [9802], limit: 50 },
        { relaySet, onEvent: (event: NDKEvent) => {
            if (seenIds.has(event.id)) return;
            seenIds.add(event.id);
            
            const aTag = event.tagValue("a");
            if (!aTag) return;
            const val = $articles.get(aTag) || { article: undefined, count: 0 };
            val.count += 1;
            $articles.set(aTag, val);

            if (val.count === 1) {
                fetchArticle(aTag, event);
            }
        } },
    )

    onDestroy(() => {
        highlights.unsubscribe();
    });

    const chronoSortedArticles = derived(articles, $articles => {
        return Array.from($articles.values())
            .filter(a => a.article)
            .map(a => a.article as NDKArticle)
            .sort(chronologically)
            .reverse();

    });

    const fetchArticle = (aTag: string, event: NDKEvent) => {
        console.log('fetching', aTag);
        $ndk.fetchEventFromTag(["a", aTag], event)
            .then(e => {
                console.log(e);
                if (e) {
                    const article = NDKArticle.from(e);
                    const val = $articles.get(aTag) || { article: null, count: 1 };
                    val.article = article;
                    articles.update($articles => {
                        $articles.set(aTag, val);
                        return $articles;
                    });
                }
            })
    }
</script>

<Feed.Articles store={chronoSortedArticles} />