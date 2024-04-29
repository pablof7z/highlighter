<script lang="ts">
	import { pageHeader } from "$stores/layout";
	import { userFollows } from "$stores/session";
	import { NDKKind, type NDKFilter, NDKEvent, NDKTag, NDKHighlight } from "@nostr-dev-kit/ndk";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import Swipe from "$components/Swipe.svelte";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable } from "svelte/store";
	import { computeArticleRecommendationFromHighlightStore } from "$utils/recommendations";
	import MostHighlightedArticleGrid from "$components/MostHighlightedArticleGrid.svelte";

    $pageHeader = {
        title: "Home",
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

    // const allEvents = $ndk.storeSubscribe({
    //     kinds: [NDKKind.Highlight, NDKKind.Text],
    //     authors: Array.from($userFollows)
    // });

    // const feed = derived(allEvents, $allEvents => {
    //     const events: NDKEvent[] = [];

    //     for (const event of $allEvents) {
    //         if (event.kind === NDKKind.Text) {
    //             if (isRootEvent(event))
    //                 events.push(event);
    //         } else if (event.kind === NDKKind.Highlight) {
    //             events.push(event);
    //         }
    //     }

    //     // Sort by date
    //     events.sort((a, b) => b.created_at! - a.created_at!);

    //     return events;
    // })

    function clicked(e: CustomEvent) {
        console.log(e)
        e.preventDefault();
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
        <MostHighlightedArticleGrid articleTagsWithHighlights={$recommendedArticles} />
    {/if}


    <section>
        <h1>Highlights & Notes</h1>

        <!-- <div class="discussion-wrapper flex flex-col w-full">
            {#each $feed as event (event.id)}
                <FeedEvent {event} />
            {/each}
        </div> -->

        <FilterFeed
            filters={highlightFilters}
            bind:feed
            renderLimit={100}
        />
        <!-- <Highlights filters={highlightFilters} /> -->
    </section>

<style>
    .bg {
        background: radial-gradient(100.21% 187.14% at 0% 0.15%, #BD9488 0%, #7092A0 100%) /* warning: gradient uses a rotation that is not supported by CSS and may not behave as expected */;
    }

    section {
        @apply w-full flex flex-col gap-5;
    }

    section h1 {
        @apply text-4xl font-semibold text-white;
    }
</style>

