<script lang="ts">
	import Carousel from "$components/Page/Carousel.svelte";
	import { Name, UserProfile, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKHighlight, NDKSubscriptionCacheUsage, NDKKind, NDKTag, NDKUserProfile, NDKList } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import { urlFromEvent } from "$utils/url";
	import { appMobileView } from "$stores/app";
	import { Chip } from "konsta/svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { onDestroy } from "svelte";
    import Article from '$components/List/Article.svelte';

    export let articleList: NDKList;
    export let authorUrl: string | undefined = undefined;
    export let userProfile: NDKUserProfile | undefined = undefined;

    let listImage: string;
    
    $: listImage = articleList.tagValue("image") ?? userProfile?.image ?? "";

    const filters = articleList.filterForItems();
    const items = $ndk.storeSubscribe(filters);

    onDestroy(() => {
        items.unsubscribe();
    });
</script>

<div class="flex flex-col">
<!-- <a href={urlFromEvent(articleList, authorUrl)} class="gap-4 relative w-full grid grid-rows-2 sticky top-[40px] bg-base-100 z-2 h-[30dvh]"> -->
    <a href={urlFromEvent(articleList, authorUrl)} class="gap-4 relative w-full grid grid-rows-2 bg-base-100 z-2 max-h-[50vh]">
        <!-- cover image -->
        <img src={listImage} alt="" class="object-cover z-1 w-full" />

        <div class="w-full absolute left-0 bottom-0 right-0 z-2 bg-gradient-to-b from-transparent via-black to-black p-4">
            <h1 class="text-2xl font-semibold mb-0 font-serif">
                {articleList.title}
            </h1>

            <h2 class="text-base-100-content text-lg">
                {articleList.description}
            </h2>

            <div class="text-xs">
                by
                <a href={authorUrl} class="text-accent2">
                    <Name user={articleList.author} {userProfile} />
                </a>
                {#if articleList.created_at}
                    /
                    {new Date(articleList.created_at*1000).toLocaleDateString()}
                {/if}
            </div>
        </div>
    </a>

    <div class="flex flex-col gap-4 my-6">
        {#each $items.slice(0, 3) as item (item.id)}
            <Article article={NDKArticle.from(item)} class="max-h-[6rem] overflow-y-clip" />
        {/each}
        {#if $items.length > 3}
            <a href={urlFromEvent(articleList, authorUrl)} class="text-accent2 text-sm">View all</a>
        {/if}
    </div>
</div>