<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
	import { userFollows } from "$stores/session";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy, onMount } from "svelte";
    import { pageHeader, pageSidebar, searching } from "$stores/layout";
	import { getNip50RelaySet } from "$utils/ndk";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import Highlight from "$components/Highlight.svelte";

    let selectedCategory: string;
    let events: NDKEventStore<NDKEvent> | undefined = undefined;

    $: selectedCategory = $page.params.category || "All";

    const authors = Array.from($userFollows);
    let key = new Date();

    function getFilters(query?: string): NDKFilter[] {
        const filters: NDKFilter[] = [ { kinds: [NDKKind.Highlight], limit: 100 } ];

        query ??= $page.url.searchParams.get("q") ?? "";

        if (query && query.length > 0) {
            // if query starts with # add it as a #t to the filter
            if (query.startsWith("#")) {
                filters[0]["#t"] = [query.slice(1)];
            } else {
                filters[0].search = query;
            }
        } else if (authors.length > 0) {
            // if there are authors add them to the filter
            filters[0].authors = authors;
        }

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
        key = new Date();
        events.onEose(() => { $searching = false; });
    }

    startSubscription();

    onDestroy(() => {
        events?.unsubscribe();
    });

    function searchFn(query: string) {
        // set q in the url
        const url = new URL(window.location.href);
        url.searchParams.set("q", query);
        window.history.replaceState({}, "", url.toString());

        startSubscription(query);
    }

    $pageHeader = {
        title: "Highlights",
        searchBar: true,
        searchFn,
    }
</script>

{#key key}
    {#each $events as event (event.id)}
        {#if event.kind === NDKKind.Highlight}
            <Highlight highlight={NDKHighlight.from(event)} />
        {:else}
            <ClipItem {event} />
        {/if}
    {/each}
{/key}