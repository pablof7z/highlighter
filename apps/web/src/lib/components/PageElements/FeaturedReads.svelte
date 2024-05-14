<script lang="ts">
	import Carousel from "$components/Page/Carousel.svelte";
	import { Name, UserProfile, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKHighlight, NDKSubscriptionCacheUsage, NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
    import Highlight from "$components/Highlight.svelte";
	import { onMount } from "svelte";
	import { urlFromEvent } from "$utils/url";

    export let article: NDKArticle | undefined = undefined;
    export let articleTag: NDKTag;
    export let highlights: NDKHighlight[];

    let loadedArticleTag: NDKTag | undefined = undefined;

    $: if (loadedArticleTag !== articleTag) {
        console.log("Fetching article for tag", articleTag);
        $ndk.fetchEventFromTag(articleTag).then((event) => {
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
    <a href={urlFromEvent(article, authorUrl)} class="flex flex-row gap-4 items-stretch py-10">
        <div class="w-1/2 flex flex-col gap-2">
            <h1 class="text-4xl font-semibold text-white mb-0">
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

            <div class="text-xl h-[5rem] overflow-y-auto relative scrollbar-hidden">
                <div class="absolute h-[1rem] bg-gradient-to-b from-transparent to-base-100 w-full bottom-0"></div>
                {article.summary}
            </div>

            {#if highlights}
                <Carousel itemCount={highlights.length} class="w-full">
                    {#each highlights as highlight (highlight.id)}
                        <div class="w-[30vw] flex-none">
                            <Highlight {highlight} skipArticle={true} compact={true} skipFooter={true} />
                        </div>
                    {/each}
                </Carousel>
            {/if}
        </div>

        <div class="w-1/2 max-h-[25rem]">
            <img src={article.image ?? userProfile?.image} alt={article.title} class="w-full h-full object-cover rounded-xl" />
        </div>
    </a>
</UserProfile>
{/if}