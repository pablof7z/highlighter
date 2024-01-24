<script lang="ts">
	import { NDKArticle, NDKVideo, NDKEvent, NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKList } from '@nostr-dev-kit/ndk';
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
    import { ndk } from "@kind0/ui-common";
	import { onDestroy, onMount } from 'svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import PostGrid from '$components/Events/PostGrid.svelte';
	import { categories } from '$utils/categories';
	import { page } from '$app/stores';
	import { getDefaultRelaySet } from '$utils/ndk';
	import FilterButtons from '$components/FilterButtons.svelte';
    import createDebug from "debug";
	import { derived, writable, type Readable } from 'svelte/store';
	import { pageHeader } from '$stores/layout';
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import ExploreFilters from './ExploreFilters.svelte';
	import CurationItem from '$components/CurationItem.svelte';
	import ListContentDvms from './ListContentDvms.svelte';

    const debug = createDebug("highlighter:explore");

    let events: NDKEventStore<NDKEvent> | undefined = undefined;
    let eventsForRender: Readable<NDKEvent[] | undefined> | undefined = undefined;
    let activeFilter: string | undefined;
    const typeFilter = writable<App.FilterType[]>(["all"]);
    let filters: NDKFilter[] | undefined;

    let filter = $page.params.category ?? "All";

    async function getFilters(filter: string, filters?: NDKFilter[]) {
        const kinds = [ NDKKind.Article, NDKKind.HorizontalVideo ];
        let newFilters: NDKFilter[];

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

                break;
            default:
                newFilters = [ { kinds, limit: 10, "#f": ["Free"] } ];
        }

        return newFilters;
    }

    $: if (activeFilter !== filter || !events) {
        activeFilter = filter;

        getFilters(filter, filters).then(subscribe);
    };

    onDestroy(() => {
        events?.unsubscribe();
    })

    function subscribe(filters: NDKFilter[]) {
        events?.unsubscribe();

        const relaySet = undefined;//getDefaultRelaySet();
        events = $ndk.storeSubscribe(
            filters,
        { relaySet, autoStart: true, groupable: false, subId: 'explore', cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY })
        debug(filters);

        eventsForRender = derived([events, typeFilter], ([$events, $typeFilter]) => {
            const events: NDKEvent[] = [];


            for (const event of $events) {
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

            return events;
        });
    }

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    $pageHeader = {
        title: "Discover",
        searchBar: true
    };

    $: if (filter) {

    }
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

<MainWrapper marginClass="w-full">
    {#if eventsForRender && $eventsForRender}
        <div class="flex flex-col gap-6 w-full">
            <ExploreFilters bind:value={filter} bind:typeFilter={$typeFilter} bind:filters />

            <div class="w-full">
                {#if filter === "add"}
                    <ListContentDvms />
                {:else if filter === "Controversial"}
                    <div class="max-w-3xl mx-auto flex flex-col items-start text-lg">
                        <div class="flex flex-col justify-between items-start w-full">
                            <h1 class="text-white text-5xl font-bold mb-2">Controversial</h1>
                            <div class="badge badge-lg bg-base-300 mb-4 text-xl text-white/80 p-4">Coming soon</div>
                        </div>

                        <h2 class="text-xl">
                            Explore controversial content.
                        </h2>
                    </div>
                {:else}
                    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-4 gap-10">
                        {#key filter}
                            {#each $eventsForRender as event (event.id)}
                                {#if event.kind === NDKKind.Article}
                                    <ArticleLink article={NDKArticle.from(event)} grid={true} />
                                {:else if event.kind === NDKKind.HorizontalVideo}
                                    <VideoLink video={NDKVideo.from(event)} grid={true} />
                                {:else if event.kind === NDKKind.GroupNote}
                                    <PostGrid {event} />
                                {:else if event.kind === NDKKind.ArticleCurationSet || event.kind === NDKKind.VideoCurationSet}
                                    <CurationItem list={NDKList.from(event)} />
                                {/if}
                            {/each}
                        {/key}
                    </div>
                {/if}
            </div>
        </div>
    {/if}
</MainWrapper>