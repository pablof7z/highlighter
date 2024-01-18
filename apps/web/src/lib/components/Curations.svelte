<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
	import { userFollows } from "$stores/session";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent, NDKArticle, NDKList } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy } from "svelte";
	import { derived, writable } from "svelte/store";
	import ArticleGrid from "./Events/ArticleGrid.svelte";
	import CurationItem from "./CurationItem.svelte";

    export let event: NDKEvent;

    const debug = createDebug("highlighter:highlights");

    const typeFilter = writable<App.FilterType[]>(["all"]);
    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    const authors = Array.from($userFollows);
    const filters: NDKFilter[] = [ { kinds: [
        NDKKind.ArticleCurationSet,
        NDKKind.VideoCurationSet,
    ], ...event.filter() } ];

    // If we have authors to filter by, add them to the filter
    if (authors.length > 0) { filters[0].authors = authors; }

    const lists = $ndk.storeSubscribe(filters, {
        groupable: false,
        subId: "curations",
        autoStart: true,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    }, NDKList);

    onDestroy(() => {
        lists?.unsubscribe();
    });

    const sortedLists = derived(lists, ($lists) => {
        if (!$lists) { return []; }

        const lists = $lists.filter((list) => {
            return list.items.length > 0;
        });

        // if the list has an image tag, sort it to the top, then sort by their created_at timestamp
        return lists.sort((a, b) => {
            const aHasImage = !!a.tagValue("image");
            const bHasImage = !!b.tagValue("image");

            if (aHasImage && !bHasImage) { return -1; }
            if (!aHasImage && bHasImage) { return 1; }

            return b.created_at! - a.created_at!;
        });
    });
</script>

<div class="flex flex-row gap-8 mx-auto mt-8 w-full">
    <div class="
        max-sm:px-[var(--mobile-body-px)] max-sm:pt-[var(--mobile-nav-bar)]
        flex-col justify-start items-start flex w-full sm:max-w-[680px]
        gap-6
    ">
        {#each $sortedLists as list}
            <CurationItem {list} />
        {/each}
    </div>
</div>