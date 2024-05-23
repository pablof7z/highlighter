<script lang="ts">
	import { pageHeader, pageNavigationOptionsValue } from "$stores/layout";
	import { userFollows } from "$stores/session";
	import { NDKKind, type NDKFilter, NDKEvent, NDKTag, NDKHighlight } from "@nostr-dev-kit/ndk";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable } from "svelte/store";
	import { computeArticleRecommendationFromHighlightStore } from "$utils/recommendations";
	import MostHighlightedArticleGrid from "$components/MostHighlightedArticleGrid.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";

    $pageNavigationOptionsValue = "Home";

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
    <div class="sticky top-[var(--navbar-height)] bg-base-100 z-50">
        <HorizontalOptionsList options={$pageHeader.subNavbarOptions} bind:value={$pageHeader.subNavbarValue} />
    </div>

    <section>
        <div>
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

<style>
    section {
        @apply w-full flex flex-col gap-5 mb-6;
    }

    section h1 {
        @apply text-3xl font-semibold text-base-100-content;
    }
</style>

