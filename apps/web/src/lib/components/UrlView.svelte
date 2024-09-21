<script lang="ts">
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import { layout } from '$stores/layout';
	// import HighlightingArea from './HighlightingArea.svelte';
	import { onDestroy } from "svelte";
	import HighlightingArea from "./Content/HighlightingArea.svelte";
	import UrlViewFooter from "./UrlViewFooter.svelte";
	import HighlightedContent from "./Content/Article/HighlightedContent.svelte";
	import HeaderShell from "./Content/HeaderShell.svelte";

    export let article: NDKArticle;
    export let editUrl: string | undefined = undefined;

    let tags: NDKTag[] = [];

    if (article.url) tags.push(["r", article.url]);

    $layout.footer = {
        component: UrlViewFooter,
        props: { article }
    }
    $layout.fullWidth = false
    $layout.forceShowNavigation = undefined;

    const highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], "#r": [article.url??""] },
        { subId: 'article-highlights' }
    )

    onDestroy(() => {
        highlights?.unsubscribe();
        $layout.footer = undefined;
    });

    $layout.title = article.title;
</script>

<svelte:head>
    <title>{article.title}</title>
</svelte:head>

<div class="w-full">
    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start flex">
                    <HeaderShell
                        skipSummary={!article.summary}
                        skipImage={true}
                        title={article.title}
                        zaps={false}
                    >
                        <svelte:fragment slot="image">
                            {#if image !== false}
                                <svelte:element
                                    this={image ? 'img' : 'div'}
                                    class="w-full object-cover bg-secondary max-h-[40vh] {$$props.imageClass??""}"
                                    {...(image ? { src: image } : {})}
                                />
                            {/if}
                        </svelte:fragment>

                        <div slot="title">
                            {article.title??"Untitled"}
                        </div>

                        <div slot="summary" class:hidden={!article.summary && !$$slots.summary}>
                            {#if article.summary}
                                <div class="text-xl">
                                    {article.summary}
                                </div>
                            {/if}
                        </div>
                    </HeaderShell>
                    
                    <HighlightingArea {tags} class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative article">
                        <HighlightedContent content={article.content} {highlights} />
                    </HighlightingArea>
                </div>
            </div>
        </div>
    </div>
</div>

<style lang="postcss">
    :global(.float-element) {
        box-shadow: 0 0 10px #000;
    }
</style>