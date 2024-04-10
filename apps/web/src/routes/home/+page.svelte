<script lang="ts">
	import Highlights from "$components/Highlights.svelte";
    import MainWrapper from "$components/Page/MainWrapper.svelte";
	import CreatorOnboardingActions from '$components/PageSidebar/CreatorOnboardingActions.svelte';
	import { pageHeader } from "$stores/layout";
	import { userFollows } from "$stores/session";
	import { NDKKind, type NDKFilter, NDKEvent } from "@nostr-dev-kit/ndk";
	import CreatorsSection from "./CreatorsSection.svelte";
	import CreatorFeed from "$components/Feed/CreatorFeed.svelte";
	import { ndk } from "@kind0/ui-common";
	import { isRootEvent } from "$utils/event";
	import FeedEvent from "$components/Feed/FeedEvent.svelte";
	import { derived } from "svelte/store";

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
</script>

<MainWrapper class="flex flex-col gap-10 w-full sm:my-10">
    <section>
        <h1>Creators</h1>
    </section>

    <section>
        <h1>Highlights & Notes</h1>

        <!-- <div class="discussion-wrapper flex flex-col w-full">
            {#each $feed as event (event.id)}
                <FeedEvent {event} />
            {/each}
        </div> -->

        <Highlights filters={highlightFilters} />
    </section>
</MainWrapper>

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

