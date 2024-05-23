<script lang="ts">
	import Carousel from "$components/Page/Carousel.svelte";
	import { Name, UserProfile, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKHighlight, NDKSubscriptionCacheUsage, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import { urlFromEvent } from "$utils/url";
	import { Chip } from "konsta/svelte";

    export let article: NDKArticle | undefined = undefined;
    export let articleTag: NDKTag | undefined = undefined;
    export let highlights: NDKHighlight[] | undefined = undefined;

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
        <a href={urlFromEvent(article, authorUrl)} class="flex flex-row gap-4 relative w-full">
            <img src={article.image ?? userProfile?.image} alt={article.title} class="w-full h-full object-cover absolute top-0 left-0 bottom-0 right-0 z-1 w-full opacity-50" />
            <div class="w-full flex flex-col gap-2 z-2 absolute bottom-0 z-2 p-4">
                {#if highlights}
                    <div class="w-fit">
                        <Chip class="!bg-accent2 !text-white !rounded">
                            {highlights.length} highlights
                        </Chip>
                    </div>
                {/if}
                
                <h1 class="text-2xl font-semibold mb-0 font-serif">
                    {article.title}
                </h1>

                <div class="text-xs">
                    by
                    <a href={authorUrl} class="text-accent2">
                        <Name user={article.author} {userProfile} />
                    </a>
                    {#if article.published_at}
                        /
                        {new Date(article.published_at*1000).toLocaleDateString()}
                    {/if}
                </div>

                <!-- {#if highlights}
                    <Carousel itemCount={highlights.length} class="w-full">
                        {#each highlights as highlight (highlight.id)}
                            <div class="w-[30vw] flex-none">
                                <Highlight {highlight} skipArticle={true} compact={true} skipFooter={true} />
                            </div>
                        {/each}
                    </Carousel>
                {/if} -->
            </div>
        </a>
</UserProfile>
{:else}
    hasn't loaded
{/if}