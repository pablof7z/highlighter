<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKHighlight } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy } from "svelte";
	import Highlight from "./Highlight.svelte";
	import HighlightNote from "./HighlightNote.svelte";
	import { derived } from "svelte/store";

    export let filter: NDKFilter | undefined = undefined;

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    export let filters: NDKFilter[] | undefined = undefined;

    if (!filters) filters = [ { kinds: [NDKKind.Highlight], ...filter } ];

    const events = $ndk.storeSubscribe(filters, {
        groupable: false,
        subId: "highlights",
        autoStart: true,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });

    onDestroy(() => {
        events?.unsubscribe();
    });

    const eventsToRender = derived(events, ($events) => {
        return $events
            .sort((a, b) => b.created_at! - a.created_at!)
            .slice(0, 10);
    });

    // const groupedHighlights = derived(events, ($events) => {
    //     // select the most recent 200 events turn those into NDKHighlights using NDKHighlight.from
    //     // and put in arrays grouping by the highlight.articleId key, return an array of arrays
    //     // of NDKHighlights where each array is a group of highlights from the same article

    //     // Keep a list of the order of the articles
    //     const highlighArticleOrder: string[] = [];

    //     // Group the highlights by articleId
    //     const highlights = $events
    //         .slice(0, 200)
    //         .map((event) => NDKHighlight.from(event))
    //         .reduce((acc, highlight) => {
    //             const articleTag = highlight.getArticleTag()?.[1];
    //             if (!articleTag) return acc;

    //             highlighArticleOrder.push(articleTag);

    //             if (!acc[articleTag]) acc[articleTag] = [];
    //             acc[articleTag].push(highlight);
    //             return acc;
    //         }, {} as Record<string, NDKHighlight[]>);

    //     // Annotate the articleIds that have already been moved to the result array
    //     const usedArticleTags = new Set();

    //     // Create the result array
    //     const result = [];

    //     // Iterate over the articleIds in the order they were added to the result array
    //     for (const articleTag of highlighArticleOrder) {
    //         if (usedArticleTags.has(articleTag)) continue;
    //         if (result.length >= 5) break;

    //         usedArticleTags.add(articleTag);

    //         // Add the highlights from the article to the result array
    //         result.push(highlights[articleTag]);
    //     }

    //     return result;
    // });
</script>

<div class="flex flex-row gap-8 mx-auto w-full">
    <div class="
        max-sm:px-[var(--mobile-body-px)]
        flex-col justify-start items-start flex w-full
        discussion-wrapper
    ">
        {#each $eventsToRender as event (event.id)}
            {#if event.kind === NDKKind.Highlight}
                <Highlight highlight={NDKHighlight.from(event)} class="bg-base-100/60" />
            {:else if event.kind === NDKKind.Text}
                <HighlightNote note={event} class="bg-base-100/60" />
            {:else}
                <ClipItem {event} class="bg-base-100/60" />
            {/if}
        {/each}
    </div>
</div>