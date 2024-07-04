<script lang="ts">
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { nip19 } from 'nostr-tools';
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { Readable, writable } from "svelte/store";
	import FeaturedReads from '$components/PageElements/FeaturedReads.svelte';
	import ArticleLink from '$components/Events/ArticleLink.svelte';
	import ArticleRenderShell from '$components/Event/Article/ArticleRenderShell.svelte';
	import EventTags from '$components/Events/EventTags.svelte';
    import { register } from 'swiper/element/bundle';
	import Highlight from '$components/Highlight.svelte';
	import ItemHeader from '$components/ItemHeader.svelte';
	import { urlFromEvent } from '$utils/url';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import HighlightBody from '$components/HighlightBody.svelte';
	import { appMobileView } from '$stores/app';
	import ArticleCard from '$components/Card/ArticleCard.svelte';

    register();

    export let highlights: Readable<NDKEvent[]>;

    let articleCount = new Map<string, number>();

    let highlightsPerArticle: Record<string, NDKHighlight[]> = {};

    $: {
        articleCount = new Map<string, number>();
        highlightsPerArticle = {};

        for (const highlight of $highlights) {
            const articleId = highlight.tagValue("a");
            if (!articleId) continue;
            const [kind, pubkey, dTag] = articleId.split(":");
            const encode = nip19.naddrEncode({
                kind: kind as any,
                pubkey,
                identifier: dTag,
            });
            articleCount.set(encode, (articleCount.get(encode) ?? 0) + 1);

            highlightsPerArticle[encode] = [...(highlightsPerArticle[encode] ?? []), highlight];
        }
    }
</script>

<div class="max-w-[var(--home-layout-feed-width)] flex flex-row-reverse gap-8">
    <div class="w-full flex flex-col gap-4">
        <h1 class="text-foreground font-semibold">
            Highlights
        </h1>

        <StoreFeed
            feed={highlights}
            eventProps={{compact: true}}
        />

        {#if false}
        {#each Array.from(articleCount.entries()).sort((a, b) => b[1] - a[1]).slice(0, 10) as [articleId, count]}
            <WithItem tagId={articleId} let:article>
                {#if article}
                    <div class="flex flex-row w-full">
                        {#if !$appMobileView}
                            <div class="w-1/4">
                                <ArticleCard {article} highlights={highlightsPerArticle[articleId]} />
                            </div>
                        {/if}
                        <!-- <h1>{article.title}</h1>
                        <div class="text-lg font-light">
                            {article.summary}
                        </div>
                        <AvatarWithName user={article.author} avatarSize="small" class="text-sm font-light" /> -->
                        <!-- <div class="w-full">
                            <ArticleRenderShell isFullVersion={true} isPreview={false}>
                                <a href={urlFromEvent(article)} slot="image" class="w-full h-full">
                                    <img src={article.image} alt={article.title} class="w-full h-auto object-cover max-h-[20vh] min-h-[5rem]" />
                                </a>

                                <a href={urlFromEvent(article)} slot="title" class="w-full h-full">
                                    {article.title}
                                </a>
                                <div slot="summary" class:hidden={!article.summary}>
                                    {article.summary}
                                </div>
                                <div slot="tags">
                                    <div class="mt-2">
                                        <AvatarWithName user={article.author} avatarSize="small" class="text-sm font-light" />
                                    </div>
                                </div>
                            </ArticleRenderShell>
                        </div> -->

                        <swiper-container
                            class="sm:w-3/4 w-full"
                            freemode
                            mousewheel
                            pagination-clickable="true"
                            auto-height="true"
                            navigation="true"
                            clickable
                            loop
                            indicators
                        >
                            {#each highlightsPerArticle[articleId] as highlight}
                                <swiper-slide class="bg-background">
                                    <div class="lg:w-4/5">
                                    <HighlightBody
                                        highlight={NDKHighlight.from(highlight)}
                                        skipArticle
                                        compact
                                    />
                                    </div>
                                </swiper-slide>
                            {/each}
                        </swiper-container>
                    </div>
                {/if}
            </WithItem>
        {/each}
        {/if}
    </div>
</div>

<style lang="postcss">
    swiper-container {
        display: flex;
        width: 100%;
    }

    swiper-slide {
        display: flex;
        justify-content: center;
    }
</style>