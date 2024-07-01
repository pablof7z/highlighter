<script lang="ts">
	import { page } from "$app/stores";
	import { userFollows } from "$stores/session";
	import { ndk } from "$stores/ndk.js";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
    import { layoutMode, searching } from "$stores/layout";
	import { getNip50RelaySet } from "$utils/ndk";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";

    $layoutMode = "single-column-focused";
    
    let selectedCategory: string;
    let events: NDKEventStore<NDKEvent> | undefined = undefined;

    $: selectedCategory = $page.params.category || "All";

    function getFilters(query?: string): NDKFilter[] {
        const filters: NDKFilter[] = [
            { kinds: [NDKKind.Highlight], limit: 1 },
            { kinds: [NDKKind.Text], "#k": [NDKKind.Highlight.toString()], limit: 100 }
        ];

        const userHasEnoughFollows = $userFollows?.size >= 100;

        // if (userHasEnoughFollows)
        //     filters[0].authors = Array.from($userFollows);

        return filters;
    }

    function getRelaySetForSubscription(filters: NDKFilter[]) {
        if (filters[0].search) {
            return getNip50RelaySet();
        }

        return undefined;
    }

    function startSubscription(query?: string) {
        events?.unsubscribe();
        $searching = true;
        const filters = getFilters(query);
        events = $ndk.storeSubscribe(filters, {
            groupable: false,
            subId: "highlights",
            autoStart: true,
            cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
            relaySet: getRelaySetForSubscription(filters),
        });
        events.onEose(() => { $searching = false; });
    }

    startSubscription();

    onDestroy(() => {
        events?.unsubscribe();
    });
</script>

<StoreFeed
    feed={events}
    eventProps={{ compact: true }}
    renderLimit={1}
/>
<!-- 
{#if $events}
    {#each $events as event (event.id)}
        {#if event.kind === NDKKind.Highlight}
            <Highlight highlight={NDKHighlight.from(event)} />
        {:else}
            <ClipItem {event} />
        {/if}
    {/each}
{/if} -->