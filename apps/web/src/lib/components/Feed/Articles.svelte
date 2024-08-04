<script lang="ts">
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { derived, Readable } from "svelte/store";
    import * as Item from './Item';
    import * as Card from '$components/Card';
	import { filterArticles } from "$utils/article-filter";
	import { isMobileBuild } from "$utils/view/mobile";
	import { appMobileView } from "$stores/app";

    export let includeLowQuality = false;
    export let store: Readable<NDKArticle[]>;
    export let featuredItems = derived(store, $store => {
        return $store.slice(0, 1);
    });

    export let skipAuthor = false;
    export let gridSetup = "lg:grid-cols-2";

    const featuredItemIds = derived(featuredItems, $featuredItems => {
        return $featuredItems.map(item => item.id);
    });

    const articles = filterArticles(store);


</script>

{#if $featuredItems.length > 0}
    <div class="flex flex-col gap-6 border-b border-border pb-[var(--section-vertical-padding)]">
        {#each $featuredItems as article}
            <Card.FeaturedArticle {article} {skipAuthor} />
        {/each}
    </div>
{/if}

<div class="flex flex-col divide-y divide-border">
    {#each $articles as article (article.id)}
        {#if !$featuredItemIds.includes(article.id)}
            <div class="py-[var(--section-vertical-padding)] w-full">
                <Item.Article
                    {article}
                    {skipAuthor}
                    class="responsive-padding"
                />
            </div>
        {/if}
    {/each}
</div>