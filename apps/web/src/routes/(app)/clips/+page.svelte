<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
    import FilterButtons from "$components/FilterButtons.svelte";
	import PageSidebar from "$components/PageSidebar.svelte";
	import { userFollows } from "$stores/session";
    import { categories } from '$utils/categories';
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { User } from "phosphor-svelte";
	import { onDestroy } from "svelte";
	import { writable } from "svelte/store";

    const debug = createDebug("highlighter:clips");

    const typeFilter = writable<App.FilterType[]>(["all"]);
    let selectedCategory: string;
    let open = false;

    $: selectedCategory = $page.params.category || "All";

    const authors = Array.from($userFollows);

    const filters: NDKFilter[] = [ { kinds: [NDKKind.Highlight], limit: 100 } ];

    // If we have authors to filter by, add them to the filter
    if (authors.length > 0) { filters[0].authors = authors; }

    const events = $ndk.storeSubscribe(filters, {
        groupable: false,
        subId: "clips",
        autoStart: true,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });

    onDestroy(() => {
        events?.unsubscribe();
    });
</script>

<div class="w-full justify-between items-center flex max-sm:hidden overflow-x-clip flex-nowrap max-w-[calc(100vw-40px)]">
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

<div class="flex flex-row gap-8 mx-auto mt-8">
    <PageSidebar title="Clips" bind:open>
        <a href="/clips/my" class="flex flex-row gap-2 items-center">
            <User class="w-5 h-5" />
            My clips
        </a>
    </PageSidebar>

    <div class="
        max-sm:px-[var(--mobile-body-px)] max-sm:pt-[var(--mobile-nav-bar)]
        flex-col justify-start items-start flex w-full sm:max-w-[680px]
        gap-6
    ">
        {#each $events as event}
            <ClipItem {event} />
        {/each}
    </div>
</div>