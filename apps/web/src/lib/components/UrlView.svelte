<script lang="ts">
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import { pageHeader } from '$stores/layout';
	import HighlightingArea from './HighlightingArea.svelte';
	import HighlightedContent from './HighlightedContent.svelte';
	import { onDestroy } from "svelte";

    export let article: NDKArticle;
    export let editUrl: string | undefined = undefined;

    console.log(article);

    let tags: NDKTag[] = [];

    if (article.url) tags.push(["r", article.url]);

    const highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], "#r": [article.url??""] },
        { subId: 'article-highlights' }
    )

    onDestroy(() => {
        highlights?.unsubscribe();
    });

    $pageHeader = { title: article?.title }
</script>

<svelte:head>
    <title>{article.title}</title>
</svelte:head>

<div class="w-full">
    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start flex">
                    <div class="self-stretch flex-col justify-start items-start gap-1 flex">
                        <div class="self-stretch text-foreground text-4xl font-medium">
                            {article.title}
                        </div>
                        <div class="flex-row justify-between items-center gap-4 flex w-full">
                            <div class="flex flex-row items-center gap-12">
                            </div>
                        </div>
                    </div>
                    <HighlightingArea {tags} class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative article">
                        <HighlightedContent content={article.content} {highlights} />
                    </HighlightingArea>
                    <!-- <article class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-7 w-full relative prose"> -->

                    <!-- </article> -->
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