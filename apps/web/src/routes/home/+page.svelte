<script lang="ts">
	import { pageNavigationOptionsValue } from "$stores/layout";
	import { userFollows } from "$stores/session";
	import { NDKKind, type NDKFilter, NDKEvent, NDKTag, NDKHighlight, NDKArticle, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable, derived } from "svelte/store";
	import { computeArticleRecommendationFromHighlightStore } from "$utils/recommendations";
	import MostHighlightedArticleGrid from "$components/MostHighlightedArticleGrid.svelte";
	import FeaturedReads from "$components/PageElements/FeaturedReads.svelte";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { ndk } from "@kind0/ui-common";
	import Highlights from "$views/Home/Sections/Highlights.svelte";
	import Articles from "$views/Home/Sections/Articles.svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";

    $pageNavigationOptionsValue = "Home";

    let feed: NDKEventStore<NDKEvent>;
    let highlights: Readable<NDKHighlight[]>;
    let articles: Readable<NDKArticle[]>;

    const relaySet = NDKRelaySet.fromRelayUrls([
        'wss://relay.highlighter.com',
        'wss://relay.primal.net'
    ], $ndk);

    $: if (!feed) {
        const userHasEnoughFollows = $userFollows?.size >= 100;

        const timeLimit = Math.floor(Date.now() / 1000) - 60 * 60 * 24 * 14;
        const filters: NDKFilter[] = [
            { kinds: [NDKKind.Highlight], limit: 500, since: timeLimit },
            { kinds: [NDKKind.Article], limit: 50 },
            { kinds: [NDKKind.Text], "#k": [NDKKind.Highlight.toString()] },
        ]

        if (userHasEnoughFollows) {
            for (const filter of filters) {
                filter.authors = Array.from($userFollows);
            }
        }

        feed = $ndk.storeSubscribe(filters, {
            groupable: false,
            subId: 'home-feed',
            relaySet
        });

        highlights = derived(feed, ($feed) => {
            return $feed.filter(e => e.kind === NDKKind.Highlight).map(e => NDKHighlight.from(e));
        });

        articles = derived(feed, ($feed) => {
            return $feed.filter(e => e.kind === NDKKind.Article).map(e => NDKArticle.from(e));
        });

        feed.onEose(() => {
            // articleTaggingEvents = $ndk.storeSubscribe(
            //     {
            //         kinds: [NDKKind.Text, NDKKind.Zap, NDKKind.Reaction, NDKKind.GenericRepost],
            //         "#a": $articles.map(a => a.tagId()),
            //         limit: 200,
            //     }, { subId: 'article-reactions', relaySet }
            // );

            sortedArticles = derived(
                [articles],
                ([$articles]
            ) => {
                // sort by published_at
                return $articles.sort((a, b) => {
                    return b.published_at! - a.published_at!;
                });

                
                // const articleTaggingCount = new Map<string, number>();

                // for (const event of $articleTaggingEvents) {
                //     const articleId = event.tagValue("a")
                //     if (!articleId) continue;

                //     const count = articleTaggingCount.get(articleId) ?? 0;
                //     articleTaggingCount.set(articleId, count + 1);
                // }

                // return $articles.sort((a, b) => {
                //     return (articleTaggingCount.get(b.tagId()) ?? 0) - (articleTaggingCount.get(a.tagId()) ?? 0);
                // })
            });
        });
    }

    let recommendedArticles: Readable<{tag: NDKTag, highlights: NDKHighlight[]}[]> | undefined;
    let featuredArticleTag: Readable<{articleTag: string, highlights: NDKHighlight[]} | undefined>;

    $: if (feed && !recommendedArticles) {
        recommendedArticles = computeArticleRecommendationFromHighlightStore(highlights);
        featuredArticleTag = derived(recommendedArticles, ($recommendedArticles) => {
            if ($recommendedArticles) {
                for (const article of $recommendedArticles) {
                    if (article.tag[0] === "a") {
                        return {
                            articleTag: article.tag[1],
                            highlights: article.highlights,
                        }
                    }
                }
            }
        });
    }

    let articleTaggingEvents: NDKEventStore<NDKEvent>;
    let sortedArticles: Readable<NDKArticle[]>;

</script>

{#if $featuredArticleTag}
<div class="max-w-[var(--home-layout-feed-width)] mx-auto w-full">
    {#if $featuredArticleTag}
        <WithItem tagId={$featuredArticleTag.articleTag} let:article>
            {#if article}
                <FeaturedReads
                    {article}
                    highlights={$featuredArticleTag.highlights}
                    loadExtraHighlights={true}
                    skipZaps={true}
                />
            {/if}
        </WithItem>
    {/if}
</div>
{/if}

{#if $recommendedArticles}
    <section class="px-10">
        <div class="sm:px-6">
            <h1 class="pt-6">
                What your friends are readings
            </h1>
            <MostHighlightedArticleGrid articleTagsWithHighlights={$recommendedArticles} />
        </div>
    </section>
{/if}
<div class="max-w-5xl mx-auto w-full">
    {#if sortedArticles}
        <section>
            <Articles articles={sortedArticles} />
        </section>
    {/if}


    <section>
        <Highlights {highlights} />
    </section>
</div>

<style>
    section {
        @apply w-full flex flex-col gap-5 mb-6;
    }

    section h1 {
        @apply text-3xl font-semibold text-base-100-content;
    }
</style>

