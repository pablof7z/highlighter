<script lang="ts">
	import { NDKArticle, NDKEvent, NDKKind, NDKRelaySet, type NDKFilter } from '@nostr-dev-kit/ndk';
	import ArticleGrid from "$components/Events/ArticleGrid.svelte";
    import { ndk } from "@kind0/ui-common";
	import { onDestroy, onMount } from 'svelte';
	import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import PostGrid from '$components/Events/PostGrid.svelte';
	import { categories } from '$utils/categories';
	import { page } from '$app/stores';
	import { getDefaultRelaySet } from '$utils/ndk';

    let events: NDKEventStore<NDKEvent> | undefined = undefined;
    let activeCategory: string | undefined;

    $: if (activeCategory !== $page.params.category || !events) {
        activeCategory = $page.params.category;

        if (events) events.unsubscribe();

        const relaySet = getDefaultRelaySet();
        const filters: NDKFilter[] = [{ kinds: [NDKKind.Article], "#f": ["Free"] }];

        if (activeCategory) {
            filters[0]["#t"] = [activeCategory];
        }

        console.log(filters);

        events = $ndk.storeSubscribe(
            filters,
        { relaySet, autoStart: true, groupable: false, subId: 'explore' })
    };

    onDestroy(() => {
        events?.unsubscribe();
    })

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";
</script>

{#if events && $events}
    <div class="flex flex-col gap-6 w-full max-w-7xl mx-auto">

        <div class="w-full justify-between items-center inline-flex max-sm:hidden">
            <div class="justify-start items-start gap-6 inline-flex">
                <div class="text-white text-opacity-60 text-sm font-semibold leading-4">Popular Categories</div>
                    {#each categories as category}
                        <a
                            href="/explore/{category}"
                            class="text-sm font-semibold leading-4"
                            class:text-white={category === selectedCategory}
                        >{category}</a>
                    {/each}
            </div>
            <div class="justify-start items-center gap-4 inline-flex">
                <div class="text-white text-opacity-60 text-sm font-semibold leading-4">Sort by</div>
                <div class="justify-start items-center gap-1 flex">
                    <div class="p-2 bg-white bg-opacity-10 rounded-lg justify-start items-center gap-1.5 flex">
                        <div class="w-5 h-5 relative"></div>
                    </div>
                    <div class="p-2 rounded-lg justify-start items-center gap-1.5 flex">
                        <div class="w-5 h-5 relative"></div>
                    </div>
                    <div class="p-2 rounded-lg justify-start items-center gap-1.5 flex">
                        <div class="w-5 h-5 relative"></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="w-full max-5xl px-4 sm:px-0">
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-10">
                {#each $events as event (event.id)}
                    {#if event.kind === NDKKind.Article}
                        <ArticleGrid article={NDKArticle.from(event)} />
                    {:else if event.kind === NDKKind.GroupNote}
                        <PostGrid {event} />
                    {/if}
                {/each}
            </div>
        </div>
    </div>
{/if}