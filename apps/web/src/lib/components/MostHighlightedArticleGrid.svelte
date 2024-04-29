<script lang="ts">
	import ArticleGridUrlItem from './ArticleGridUrlItem.svelte';
    import Carousel from './Page/Carousel.svelte';

	import { NDKHighlight, NDKTag } from "@nostr-dev-kit/ndk";
	import ArticleGridArticle from './ArticleGridArticle.svelte';

    export let articleTagsWithHighlights: {tag: NDKTag, highlights: NDKHighlight[]}[];
    export let limit = 10;
</script>

{#if articleTagsWithHighlights && articleTagsWithHighlights.length > 0}
<div class="mb-4">
    <Carousel
        class="overflow-auto w-full gap-6"
        itemCount={articleTagsWithHighlights.length}
    >
        {#each articleTagsWithHighlights.slice(0, 20) as {tag: articleTag, highlights}}
            {#if articleTag[0] === "a"}
                <ArticleGridArticle tag={articleTag} {highlights} />
            {:else if articleTag[0] === 'r'}
                <ArticleGridUrlItem url={articleTag[1]} {highlights} />
            {/if}
        {/each}
    </Carousel>
</div>
{/if}