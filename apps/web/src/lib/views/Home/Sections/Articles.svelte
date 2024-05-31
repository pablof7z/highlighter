<script lang="ts">
	import Tags from "$components/Events/Tags.svelte";
import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { filterArticle } from "$utils/article-filter";
	import { blacklistedTags } from "$utils/const";
	import { NDKArticle, NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { Readable, derived } from "svelte/store";

    export let articles: Readable<NDKArticle[]>;
    export let start: number = 0;
    export let end: number = 7;

    const filteredArticles = derived(articles, ($articles) => {
        return filterArticle(articles)
            .slice(start, end);
    });

    const tags = derived(filteredArticles, ($filteredArticles) => {
        const tags = new Map<string, number>();

        for (const article of $filteredArticles) {
            for (const tag of article.getMatchingTags("t").slice(0, 10)) {
                if (blacklistedTags.has(tag[1])) continue;
                tags.set(tag[1].toLocaleLowerCase(), (tags.get(tag[1]) ?? 0) + 1);
            }
        }

        return Array.from(tags.entries())
            .sort((a, b) => b[1] - a[1])
            .slice(5, 15);
    });
</script>

<div class="max-w-[var(--home-layout-feed-width)] w-full flex flex-row-reverse gap-8">
    <div class="w-3/4 mx-auto">
        <StoreFeed
            feed={filteredArticles}
        />
    </div>

    <div class="hidden md:flex w-1/4 sticky top-[var(--navbar-height)] flex-col gap-4 max-h-screen overflow-y-auto items-end">
        <h1 class="text-white font-semibold">
            Articles
        </h1>
        
        {#each $tags as [tag, count] (tag)}
            <a
                href="/t/{encodeURIComponent(tag)}"
                class="flex-row gap-2 text-base-100-content text-sm inline flex-inline bg-white/10 rounded-full px-3 py-1 whitespace-nowrap w-fit"
            >
                <span class="opacity-30">#</span><span class="opacity-80">{tag}</span>
            </a>
        {/each}
    </div>

    <!-- <FilterFeed
        filters={highlightFilters}
        bind:feed
        renderLimit={10}
    /> -->
</div>