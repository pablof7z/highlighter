<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKArticle } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
    import * as Feed from "$components/Feed";
	import { filterArticles } from "$utils/article-filter";

    const curations = $ndk.storeSubscribe(
        [{ kinds: [NDKKind.GenericRepost], "#k": ["30023"], limit: 100 }],
        { subId: 'home-top-curation', closeOnEose: true },
    );

    let articles = derived(curations, ($curations) => {
        const keys = new Set();
        
        return $curations
            .map(c => {
                try {
                    return JSON.parse(c.content);
                } catch {}
            })
            .filter(c => c)
            .map(c => {
                const a = NDKArticle.from(c)
                a.ndk = $ndk;
                return a;
            })
            .filter(a => {
                const tag = a.tagId();
                const hasKey = keys.has(tag);
                if (!hasKey) keys.add(tag);
                return !hasKey;
            })
    })
</script>

<Feed.Articles
    store={filterArticles(articles)}
/>