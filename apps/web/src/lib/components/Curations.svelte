<script lang="ts">
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent, NDKList } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy } from "svelte";
	import { derived, writable } from "svelte/store";
	import CurationItem from "./CurationItem.svelte";

    export let filter: NDKFilter;
    export let skipAuthor: boolean | undefined = undefined;

    const debug = createDebug("HL:curations");

    const typeFilter = writable<App.FilterType[]>(["all"]);
    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    const filters: NDKFilter[] = [ { kinds: [
        NDKKind.ArticleCurationSet,
        NDKKind.VideoCurationSet,
    ], ...filter } ];

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

<div class="flex flex-row mx-auto w-full">
    <div class="
        max-sm:px-[var(--mobile-body-px)]
        flex-col justify-start items-start flex
        w-full
        discussion-wrapper
    ">
        {#each $sortedLists as list (list.id)}
            {#if list.items.length > 0}
                <CurationItem {list} grid={false} {skipAuthor} />
            {/if}
        {/each}
    </div>
</div>