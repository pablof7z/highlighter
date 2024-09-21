<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { filterArticles } from "$utils/article-filter";
	import { NDKArticle, NDKFilter, NDKKind, NDKList, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import * as Feed from "$components/Feed";
	import { CaretRight, MagnifyingGlass } from "phosphor-svelte";
	import { userFollows } from "$stores/session";

    const oneWeekAgo = Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 7;

    const recentArticlesFromFollows = $ndk.storeSubscribe([
        { kinds: [NDKKind.Article], authors: Array.from($userFollows), since: oneWeekAgo },
        { kinds: [NDKKind.GenericRepost], "#k": [NDKKind.Article.toString()], authors: Array.from($userFollows), since: oneWeekAgo },
    ], { closeOnEose: true }, NDKArticle);

    const articleComments = $ndk.storeSubscribe([
        // { kinds: [NDKKind.Text, NDKKind.Zap, NDKKind.Nutzap, NDKKind.GenericRepost ], "#k": ["30023"], limit: 50 },
        { kinds: [NDKKind.ArticleCurationSet ], limit: 50 },
    ], { closeOnEose: true, onEose: () => {
        loadArticles();
    }}, NDKList)

    let articles: NDKEventStore<NDKArticle>;

    function loadArticles() {
        const filter: NDKFilter = {kinds:[NDKKind.Article], authors:[], "#d": [], limit: 200};

        $articleComments.forEach(comment => {
            const aTag = comment.getMatchingTags("a")
                .filter(tag => tag[1].startsWith("30023:"))
                ?.[0]?.[1];
            
            if (aTag) {
                const [kind, pubkey, dTag] = aTag.split(":");
                if (dTag.length > 0) {
                    filter.authors!.push(pubkey);
                    filter["#d"]!.push(dTag);
                }
            }
        });

        if (filter.authors!.length > 0) {
            articles = $ndk.storeSubscribe(
                filter,
                { subId: 'articles' },
                NDKArticle
            );
        }
    }
</script>

<div class="flex flex-col w-full max-w-[var(--content-focused-width)]">
    <Feed.Articles
        store={filterArticles(recentArticlesFromFollows)}
    />
</div>
{#if articles}
    <div class="flex flex-col w-full max-w-[var(--content-focused-width)]">
        <!-- <a href="/reads" class="
            flex flex-row justify-between max-sm:w-full py-2 responsive-padding z-10
        ">
            <div class="section-title">
                Nostr Reads
            </div>

            <CaretRight size={24} />
        </a>
 -->
        <Feed.Articles
            store={articles}
        />
        <a href="/reads" class="bg-secondary flex flex-row justify-between max-sm:w-full py-4 responsive-padding">
            <div>
                <MagnifyingGlass size={24} class="inline" />
                Explore more great reads
            </div>

            <CaretRight size={24} />
        </a>
    </div>
{/if}