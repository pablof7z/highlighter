<script lang="ts">
	import { NDKArticle, NDKVideo, NDKEvent, NDKKind, type NDKFilter, NDKList, NDKRelaySet } from '@nostr-dev-kit/ndk';
	import ArticleLink from "$components/Events/ArticleLink.svelte";
    import { ndk } from "$stores/ndk.js";
	import { onDestroy } from 'svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { page } from '$app/stores';
    import createDebug from "debug";
	import { derived, writable, type Readable } from 'svelte/store';
	import { layoutMode, pageHeader, resetLayout } from '$stores/layout';
	import ListContentDvms from './ListContentDvms.svelte';
	import { mainContentKinds } from '$utils/event';
	import { browser } from '$app/environment';
	import { blacklistedPubkeys } from '$utils/const';
	import { getDefaultRelaySet } from '$utils/ndk';
	import VideoLink from '$components/Events/VideoLink.svelte';
	import PostGrid from '$components/Events/PostGrid.svelte';
	import CurationItem from '$components/CurationItem.svelte';

    $layoutMode = "full-width";

    onDestroy(resetLayout)
    
    const debug = createDebug("HL:explore");

    let events: NDKEventStore<NDKEvent> | undefined = undefined;
    let eventsForRender: Readable<NDKEvent[] | undefined> | undefined = undefined;
    let activeFilter: string | undefined;
    const typeFilter = writable<App.FilterType[]>(["all"]);
    let filters: NDKFilter[] | undefined;
    let relaySet: NDKRelaySet | undefined;

    let filter = $page.params.category ?? "All Creators";

    function getFiltersWithQuery(query: string) {
        let kinds: NDKKind[] = []

        if ($typeFilter.includes("all")) kinds = mainContentKinds;
        if ($typeFilter.includes("article")) kinds.push(NDKKind.Article);
        if ($typeFilter.includes("video")) kinds.push(NDKKind.HorizontalVideo);
        if ($typeFilter.includes("curation")) kinds.push(NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet);

        if (query.startsWith("#")) {
            filters = [ { kinds, "#t": [ query ] } ]
        } else {
            filters = [ { search: query, kinds } ]
        }

        return filters;
    }

    async function getFilters(filter: string, filters?: NDKFilter[], query?: string) {
        const kinds = [ NDKKind.Article, NDKKind.HorizontalVideo ];
        let newFilters: NDKFilter[];

        if (query) return getFiltersWithQuery(query);
        if (filters) return filters;

        switch (filter) {
            case "Curated":
                if ($typeFilter.includes("curation")) {
                    return [{
                        kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet]
                    }]
                }

                newFilters = []

                const lists = await $ndk.fetchEvents({ kinds: [NDKKind.ArticleCurationSet, NDKKind.VideoCurationSet, NDKKind.BookmarkSet], limit: 100 });

                for (const event of lists) {
                    const list = NDKList.from(event);
                    newFilters.push(...list.filterForItems())
                }
                relaySet = undefined;

                break;
            case "Network":
                const oneDayAgo = Math.floor(Date.now() / 1000) - 86400;
                newFilters = [ { kinds, limit: 100, since: oneDayAgo } ];
                relaySet = undefined;
                break;
            case "All Creators":
                newFilters = [ { kinds, limit: 100 } ];
                relaySet = getDefaultRelaySet();
            default:
                newFilters = [ { kinds, limit: 100 } ];
                console.log("filter", filter);
                relaySet = undefined;
        }

        return newFilters;
    }

    $: if (activeFilter !== filter || !events) {
        activeFilter = filter;
        let query: string | undefined;

        if (browser) {
            query = $page.url.searchParams.get("q") ?? undefined;
        }

        getFilters(filter, filters).then(subscribe);
    };

    onDestroy(() => {
        events?.unsubscribe();
    })

    function subscribe(filters: NDKFilter[]) {
        debug("subscribing to events", filters, {needsToUnsubscribe: !!events});
        events?.unsubscribe();

        events = $ndk.storeSubscribe(
            filters,
        { relaySet, autoStart: true, groupable: false, subId: 'explore' })
        debug(filters);

        eventsForRender = derived([events, typeFilter], ([$events, $typeFilter]) => {
            let events: NDKEvent[] = [];

            for (const event of $events) {
                // There is a bug in the relay, for now filter out events with a tier tag
                // if (event.tagValue("tier") && ) continue;
                if (blacklistedPubkeys.includes(event.pubkey)) continue;

                if ($typeFilter.includes("all")) {
                    events.push(event);
                } else if ($typeFilter.includes("article") && event.kind === NDKKind.Article) {
                    events.push(event);
                } else if ($typeFilter.includes("video") && event.kind === NDKKind.HorizontalVideo) {
                    events.push(event);
                } else if ($typeFilter.includes("curation") && (
                    event.kind === NDKKind.ArticleCurationSet || event.kind === NDKKind.VideoCurationSet
                )) {
                    events.push(event);
                }
            }

            // filter out preview events that reference a full event we already have
            events = events.filter((event) => {
                const fullTag = event.tagValue("full");
                if (!fullTag) return true;
                if (events.find((e: NDKEvent) => e.tagAddress() === fullTag)) return false;
                return true;
            });

            // sort by published_at
            events = events.sort((a, b) => {
                let aDate = a.published_at ?? a.created_at;
                let bDate = b.published_at ?? b.created_at;
                return bDate! - aDate!;
            });

            // filter out bad events
            events = events.filter((event) => {
                return (event.tagValue("title") && event.tagValue("image"));
            });

            if (filter === "All Creators") {
                events = events.filter((event) => {
                    return !!event.tagValue("h")
                });
            }

            if (filter === "Network") {
                events = events.filter(hasImage);
                // return wotFiltered(events);
            }

            return events;
        });
    }

    const hasImage = (event: NDKEvent) => {
        if (event.kind === NDKKind.Article || event.kind === NDKKind.HorizontalVideo) {
            return !!event.tagValue("image");
        }

        return false;
    }

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    function searchFn(query: string) {
        // set q in the url
        const url = new URL(window.location.href);
        url.searchParams.set("q", query);
        window.history.replaceState({}, "", url.toString());

        getFilters(filter, filters, query).then(subscribe);
    }

    $pageHeader = {
        searchBar: true,
        title: "Discover",
        searchFn,
    };
</script>

<svelte:head>
    {#if selectedCategory && selectedCategory !== "All"}
        <meta name="description" content={`Explore ${selectedCategory} on Nostr`} />
        <title>{selectedCategory} | Highlighter</title>
    {:else}
        <meta name="description" content="Explore what creators are publishing" />
        <title>Highlighter: A sanctuary for creativity</title>
    {/if}
</svelte:head>

    {#if eventsForRender && $eventsForRender}
        <div class="flex flex-col gap-6 w-full">
            <!-- <ExploreFilters bind:value={filter} bind:typeFilter={$typeFilter} bind:filters /> -->

            <div class="w-full">
                {#if filter === "add"}
                    <h1 class="text-5xl mb-2 font-bold">
                        Coming Soon
                    </h1>
                    <h2 class="text-2xl !text-foreground/70 mb-4">
                        Content Discovery DVMs
                    </h2>
                    <ListContentDvms />
                {:else if filter === "Controversial"}
                    <div class="max-w-3xl mx-auto flex flex-col items-start text-lg">
                        <div class="flex flex-col justify-between items-start w-full">
                            <h1 class="text-foreground text-5xl font-bold mb-2">Controversial</h1>
                            <div class="badge badge-lg bg-foreground/20 mb-4 text-xl text-foreground/80 p-4">Coming soon</div>
                        </div>

                        <h2 class="text-xl">
                            Explore controversial content.
                        </h2>
                    </div>
                {:else}
                    <!-- <WelcomeGridItem /> -->
                    <div class="flex flex-col sm:grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-3 xl:grid-cols-4 gap-6 sm:gap-10">
                        {#key filter}
                            {#each $eventsForRender as event (event.id)}
                                {#if event.kind === NDKKind.Article}
                                    <ArticleLink article={NDKArticle.from(event)} grid={true} class="row-span-2" />
                                {:else if event.kind === NDKKind.HorizontalVideo}
                                    <VideoLink video={NDKVideo.from(event)} grid={true} />
                                {:else if event.kind === NDKKind.GroupNote}
                                    <PostGrid {event} />
                                {:else if event.kind === NDKKind.ArticleCurationSet || event.kind === NDKKind.VideoCurationSet}
                                    <CurationItem list={NDKList.from(event)} grid={true} />
                                {/if}
                            {/each}
                        {/key}
                    </div>
                {/if}
            </div>
        </div>
    {/if}