<script lang="ts">
	import { Highlights } from '$components/Highlights.svelte';
	import Carousel from "$components/Page/Carousel.svelte";
	import { NDKArticle, NDKHighlight, NDKSubscriptionCacheUsage, NDKKind, NDKTag, NDKRelay, NDKRelaySet, NDKFilter } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import { urlFromEvent } from "$utils/url";
	import { Chip } from "konsta/svelte";
	import HighlightBody from "$components/HighlightBody.svelte";
	import TopPlusRecentZaps from "$components/Events/Zaps/TopPlusRecentZaps.svelte";
    import { register } from 'swiper/element/bundle';
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { Readable, derived, writable } from "svelte/store";
	import EventTags from '$components/Events/EventTags.svelte';

    register();

    export let article: NDKArticle | undefined = undefined;
    export let articleTag: NDKTag | undefined = undefined;
    export let highlights: NDKHighlight[] | undefined = undefined;
    export let loadExtraHighlights = false;
    export let skipZaps = false;

    let loadedArticleTag: NDKTag | undefined = undefined;

    $: if (loadedArticleTag !== articleTag && articleTag && !article) {
        loadedArticleTag = articleTag;
        console.log("Fetching article for tag", articleTag);
        $ndk.fetchEventFromTag(articleTag, {
            // cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE
        }).then((event) => {
            if (event) {
                article = NDKArticle.from(event);
            } else {
                console.error("No event found for tag", articleTag);
            }
        });
    }

    let extraHighlights: NDKEventStore<NDKHighlight> | undefined = undefined;
    let dedupedExtraHighlights: Readable<NDKHighlight[]> | undefined = undefined;

    const highlightStore = writable<NDKHighlight[]>([]);
    $: if (highlights) highlightStore.set(highlights);

    if (loadExtraHighlights) {
        const relaySet = NDKRelaySet.fromRelayUrls([
            'wss://relay.highlighter.com',
        ], $ndk);

        let filter: NDKFilter | undefined = articleTag ? { "#a": articleTag } : undefined;
        if (article) {
            filter = article.filter();
        }
        
        extraHighlights = $ndk.storeSubscribe({
            kinds: [NDKKind.Highlight],
            limit: 100,
            ...filter
        }, { relaySet, closeOnEose: true, groupable: true, groupableDelay: 250, groupableDelayType: 'at-most' });

            dedupedExtraHighlights = derived(
                [extraHighlights, highlightStore],
                ([$extraHighlights, $highlightStore]) => {
                    return  $extraHighlights
                        .filter(e => !$highlightStore.find(h => h.id === e.id)) ?? [];
                });
    }

    // const featuredArticleIds = [
    //     "naddr1qqv9yetkd9jhw6twvuk4yetkd9jhwuedd3cxjmncvvpzq6ksswfdrw4r7mlh49qfu2k9u4zrtpextk955kquvpna3r4rq9vyqvzqqqr4guc7ry3k",
    //     "naddr1qqxnzde3xymnvvfcxvmrswf4qgsph3c2q9yt8uckmgelu0yf7glruudvfluesqn7cuftjpwdynm2gygrqsqqqa2847sjwu",
    //     "naddr1qqf5jmnxd3sk6mtpw35k7m3d093rxardwqpzq6knu235sx9320yp7jx93azw2xv70d8u3klr0qg2qqxuu0yska6qqvzqqqr4gulymn28",
    //     "naddr1qq2ky6zsffx4smzvdauz64t4xphygamjg404sq3qdtf79g6grzc48jqlfrzc7389rx08kn7gm03hsy9qqrww8jgtwaqqxpqqqp65wu255mp"
    // ];
    // const id = featuredArticleIds[Math.floor(Math.random() * featuredArticleIds.length)];
</script>

{#if article}
<UserProfile user={article.author} let:authorUrl let:userProfile>
    <a href={urlFromEvent(article, authorUrl)} class="flex flex-row gap-4 relative w-full lg:min-h-[max(50vh,10rem)] overflow-hidden">
        <img src={article.image ?? userProfile?.image} alt={article.title} class="h-full object-cover absolute top-0 left-0 bottom-0 right-0 z-1 w-full opacity-50" />
        <div class="w-full flex flex-col gap-2 z-2 absolute bottom-0 z-2 p-4">
            {#if highlights}
                <div class="flex flex-row gap-4 flex-nowrap overflow-x-auto scrollbar-hide items-end -mx-4 px-4">
                    {#each highlights as highlight (highlight.id)}
                        <HighlightBody
                            {highlight}
                            class="bg-base-100/50 px-6 py-4 rounded-box backdrop-blur-2xl w-96"
                            skipArticle={true} compact={true} skipFooter={true} />
                    {/each}
                    {#if $dedupedExtraHighlights}
                        {#each $dedupedExtraHighlights as highlight (highlight.id)}
                            <HighlightBody
                                {highlight}
                                class="bg-base-100/50 px-6 py-4 rounded-box backdrop-blur-2xl w-96"
                                skipArticle={true} compact={true} skipFooter={true} />
                        {/each}
                    {/if}
                </div>
            {/if}
            
            {#if highlights}
                <div class="w-fit">
                    <Chip class="!bg-accent !text-white !rounded">
                        {highlights.length + $dedupedExtraHighlights?.length ?? 0} highlights
                    </Chip>
                </div>
            {/if}
            
            <div class="flex flex-row justify-between w-full">
                <div class="flex flex-col">
                    <h1 class="text-3xl font-semibold mb-1 font-serif whitespace-nowrap">
                        {article.title}
                    </h1>

                    <div class="text-xs whitespace-nowrap">
                        by
                        <a href={authorUrl} class="text-accent">
                            <Name user={article.author} {userProfile} />
                        </a>
                        {#if article.published_at}
                            /
                            {new Date(article.published_at*1000).toLocaleDateString()}
                        {/if}
                    </div>
                </div>

                {#if !skipZaps}
                    <div class="flex flex-row items-center text-zinc-500 w-full max-sm:my-2">
                        <div class="flex flex-row gap-2 w-full">
                            <TopPlusRecentZaps event={article} count={3} class="text-xs"  />
                        </div>
                    </div>
                {/if}
            </div>

            <EventTags event={article} class="flex flex-row gap-2" />
        </div>
    </a>
</UserProfile>
{:else}
    hasn't loaded
{/if}