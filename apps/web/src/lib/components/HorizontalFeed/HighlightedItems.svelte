<script lang="ts">
	import { ScrollArea } from "$components/ui/scroll-area";
	import { NDKHighlight, NDKTag } from "@nostr-dev-kit/ndk";
	import { Readable, writable } from "svelte/store";
	import HighlightedItem from "./HighlightedItem.svelte";
	import { inview } from "svelte-inview";

    export let highlights: Readable<NDKHighlight[]>;
    export let renderLimit = 1;

    const seenTags = new Set<string>();
    const highlightedTags = writable<NDKTag[]>([]);
    const tagsToHighlightMap = new Map<NDKTag, NDKHighlight>();

    $: for (const highlight of $highlights) {
        const tag = highlight.getArticleTag();
        if (tag && !seenTags.has(tag[1])) {
            seenTags.add(tag[1]);
            highlightedTags.update(tags => [...tags, tag]);
            tagsToHighlightMap.set(tag, highlight);
        }
    }
</script>

<ScrollArea orientation="horizontal">
    <div class="flex flex-row gap-4 w-max">
        {#each $highlightedTags.slice(0, renderLimit) as tag (tag)}
            <HighlightedItem {tag} highlight={tagsToHighlightMap.get(tag)} />
        {/each}

        <button class="opacity-0 h-0" on:click={() => { renderLimit++; }} use:inview on:inview_change={(e) => {
            if (e.detail.inView) {
                renderLimit += 10;
            }
        }}>
            load more
        </button>
    </div>
</ScrollArea>