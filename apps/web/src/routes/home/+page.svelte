<script lang="ts">
	import { pageHeader, pageNavigationOptionsValue } from "$stores/layout";
	import { userFollows } from "$stores/session";
	import { NDKKind, type NDKFilter, NDKEvent, NDKTag, NDKHighlight } from "@nostr-dev-kit/ndk";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable } from "svelte/store";
	import { computeArticleRecommendationFromHighlightStore } from "$utils/recommendations";
	import MostHighlightedArticleGrid from "$components/MostHighlightedArticleGrid.svelte";
    import { PageTransition } from 'sveltekit-page-transitions';

    $pageNavigationOptionsValue = "Home";

    $pageHeader = {
        searchBar: true
    }
    
    let highlightFilters: NDKFilter[];

    $: {
        const userHasEnoughFollows = $userFollows?.size >= 100;

        const filters: NDKFilter[] = [
            { kinds: [NDKKind.Highlight], },
            { kinds: [NDKKind.Text], "#k": [NDKKind.Highlight.toString()] },
        ]

        if (userHasEnoughFollows) {
            for (const filter of filters) {
                filter.authors = Array.from($userFollows);
            }
        }

        highlightFilters = filters;
    }

    let feed: NDKEventStore<NDKEvent>;

    let recommendedArticles: Readable<{tag: NDKTag, highlights: NDKHighlight[]}[]> | undefined;

    $: if (feed && !recommendedArticles) {
        recommendedArticles = computeArticleRecommendationFromHighlightStore(feed);
    }
</script>

    <!-- <section>
        <h1>Creators</h1>
    </section> -->

<PageTransition>
{#if $recommendedArticles}
    <section>
        <div class="sm:px-6">
            <h1 class="pt-6">
                For You
            </h1>
            <MostHighlightedArticleGrid articleTagsWithHighlights={$recommendedArticles} />
        </div>
    </section>
{/if}

    <section>
        <div>
            <h1 class="sm:p-6">Highlights</h1>
    
            <!-- <div class="discussion-wrapper flex flex-col w-full">
                {#each $feed as event (event.id)}
                    <FeedEvent {event} />
                {/each}
            </div> -->
    
            <FilterFeed
                filters={highlightFilters}
                bind:feed
                renderLimit={10}
            />
        </div>
        <!-- <Highlights filters={highlightFilters} /> -->
    </section>
</PageTransition>

<style>
    section {
        @apply w-full flex flex-col gap-5 mb-6;
    }

    section h1 {
        @apply text-3xl font-semibold text-base-100-content;
    }
</style>

