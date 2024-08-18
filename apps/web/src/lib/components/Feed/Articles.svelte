<script lang="ts">
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { derived, Readable } from "svelte/store";
    import * as Item from './Item';
    import * as Card from '$components/Card';
	import { filterPreviewArticles } from "$utils/article-filter";

    export let store: Readable<NDKArticle[]>;
    export let featuredCount = 1;

    let filteredStore = filterPreviewArticles(store);
    
    export let featuredItems = derived(filteredStore, $filteredStore => {
        return $filteredStore.slice(0, featuredCount);
    });

    export let skipAuthor = false;

    const featuredItemIds = derived(featuredItems, $featuredItems => {
        return $featuredItems.map(item => item.id);
    });

    const articlesWithoutFeatured = derived([filteredStore, featuredItemIds], ([$filteredStore, $featuredItemIds]) => {
        return $filteredStore.filter(article => !$featuredItemIds.includes(article.id));
    });

</script>

{#if $featuredItems.length > 0}
    <div class="flex flex-col gap-6 border-b border-border pb-[var(--section-vertical-padding)]">
        {#each $featuredItems as article (article.id)}
            <Card.FeaturedArticle {article} {skipAuthor} {...$$props.itemProps??{}} />
        {/each}
    </div>
{/if}

<div class="flex flex-col divide-y divide-border">
    {#each $articlesWithoutFeatured as article, index (article.id)}
        <div class="py-[var(--section-vertical-padding)] w-full">
            <Item.Article
                {index}
                {article}
                {skipAuthor}
                {...$$props.itemProps??{}}
                class="responsive-padding"
            >
            </Item.Article>
        </div>
    {/each}
</div>