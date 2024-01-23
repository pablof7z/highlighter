<script lang="ts">
	import { NDKArticle, NDKVideo, NDKEvent, NDKKind, type NDKFilter, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
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

    const debug = createDebug("highlighter:explore");

    let events: NDKEventStore<NDKEvent> | undefined = undefined;
    let eventsForRender: Readable<NDKEvent[] | undefined> | undefined = undefined;
    let activeCategory: string | undefined;
    const typeFilter = writable<App.FilterType[]>(["all"]);

    $: if (activeCategory !== $page.params.category || !events) {
        activeCategory = $page.params.category;

        if (events) events.unsubscribe();

        const relaySet = getDefaultRelaySet();
        const filters: NDKFilter[] = [
            { kinds: [
                NDKKind.Article,
                NDKKind.HorizontalVideo,
            ]},
        ];

        if (activeCategory) {
            filters[0]["#t"] = [activeCategory];
        }

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
                }
            }

            return events;
        });
    };

    onDestroy(() => {
        events?.unsubscribe();
    })

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    $pageHeader = {
        title: "Discover",
        searchBar: true
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

<MainWrapper marginClass="w-full">
    {#if eventsForRender && $eventsForRender}
        <div class="flex flex-col gap-6 w-full">
            <div class="w-full justify-between items-center flex max-sm:hidden overflow-x-clip flex-nowrap border-b border-base-300 py-2">
                <div class="justify-start items-start gap-6 flex whitespace-nowrap flex-shrink">
                    <div class="text-white text-opacity-60 text-sm font-semibold leading-4">Popular Categories</div>
                        {#each categories as category}
                            <a
                                href="/explore/{category}"
                                class="text-sm font-semibold leading-4"
                                class:text-white={category === selectedCategory}
                            >{category}</a>
                        {/each}
                </div>
                <FilterButtons bind:filters={$typeFilter} />
            </div>

            <div class="w-full max-2xl">
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-4 gap-10">
                    {#each $eventsForRender as event (event.id)}
                        {#if event.kind === NDKKind.Article}
                            <ArticleLink article={NDKArticle.from(event)} grid={true} />
                        {:else if event.kind === NDKKind.HorizontalVideo}
                            <VideoLink video={NDKVideo.from(event)} grid={true} />
                        {:else if event.kind === NDKKind.GroupNote}
                            <PostGrid {event} />
                        {/if}
                    {/each}
                </div>
            </div>
        </div>
    {/if}
</MainWrapper>