<script lang="ts">
    import * as Card from '$components/Card';

	import { NDKHighlight, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";

    export let articleTagsWithHighlights: {tag: NDKTag, highlights: NDKHighlight[]}[];
</script>

{#if articleTagsWithHighlights && articleTagsWithHighlights.length > 0}
<div class="mb-4 overflow-x-auto w-full flex-nowrap flex flex-row gap-4">
        {#each articleTagsWithHighlights.slice(0, 20) as {tag: articleTag, highlights} (articleTag[1])}
            {#if articleTag[0] === "a"}
                {#if articleTag[1].split(':')[0] === NDKKind.Article.toString()}
                    <Card.Article tag={articleTag} {highlights} />
                {:else if articleTag[1].split(':')[0] === NDKKind.HorizontalVideo.toString()}
                    <Card.Video tag={articleTag} {highlights} />
                {/if}
            {:else if articleTag[0] === 'r'}
                <Card.Url url={articleTag[1]} {highlights} />
            {/if}
        {/each}
</div>
{/if}