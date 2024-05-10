<script lang="ts">
	import EventTags from "$components/Events/EventTags.svelte";
	import Carousel from "$components/Page/Carousel.svelte";
	import { Name, UserProfile, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKHighlight, NDKSubscriptionCacheUsage, NDKKind } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
    import Highlight from "$components/Highlight.svelte";

    const ids = [
        "naddr1qqv9yetkd9jhw6twvuk4yetkd9jhwuedd3cxjmncvvpzq6ksswfdrw4r7mlh49qfu2k9u4zrtpextk955kquvpna3r4rq9vyqvzqqqr4guc7ry3k",
        "naddr1qqxnzde3xymnvvfcxvmrswf4qgsph3c2q9yt8uckmgelu0yf7glruudvfluesqn7cuftjpwdynm2gygrqsqqqa2847sjwu",
        "naddr1qqf5jmnxd3sk6mtpw35k7m3d093rxardwqpzq6knu235sx9320yp7jx93azw2xv70d8u3klr0qg2qqxuu0yska6qqvzqqqr4gulymn28",
        "naddr1qq2ky6zsffx4smzvdauz64t4xphygamjg404sq3qdtf79g6grzc48jqlfrzc7389rx08kn7gm03hsy9qqrww8jgtwaqqxpqqqp65wu255mp"
    ];
    const id = ids[Math.floor(Math.random() * ids.length)];

    let main: NDKArticle;
    let mainHighlights: NDKEventStore<NDKHighlight>;

    $ndk.fetchEvent(id, { cacheUsage: NDKSubscriptionCacheUsage.ONLY_CACHE})
    .then((e) => {
        if (e) {
            main = NDKArticle.from(e);
            mainHighlights = $ndk.storeSubscribe(
                { kinds: [NDKKind.Highlight], ...main.filter()},
                undefined,
                NDKHighlight
            )
        }
    })
</script>

{#if main}
    <UserProfile user={main.author} let:authorUrl let:userProfile>
        <div class="flex flex-row gap-4 items-stretch py-10">
            <div class="w-1/2 flex flex-col gap-2">
                <h1 class="text-4xl font-semibold text-white mb-0">
                    {main.title}
                </h1>

                <div class="text-xs">
                    by
                    <a href={authorUrl} class="text-accent2">
                        <Name user={main.author} {userProfile} />
                    </a>
                    {#if main.published_at}
                        /
                        {new Date(main.published_at*1000).toLocaleDateString()}
                    {/if}
                </div>

                <div class="text-xl h-[5rem] overflow-y-auto relative scrollbar-hidden">
                    <div class="absolute h-[1rem] bg-gradient-to-b from-transparent to-base-100 w-full bottom-0"></div>
                    {main.summary}
                </div>

                {#if $mainHighlights}
                <Carousel itemCount={$mainHighlights.length} class="w-full">
                    {#each $mainHighlights as highlight (highlight.id)}
                        <div class="w-[30vw] flex-none">
                            <Highlight {highlight} skipArticle={true} compact={true} skipFooter={true} />
                        </div>
                    {/each}
                </Carousel>
                {/if}
            </div>

            <div class="w-1/2 max-h-[25rem]">
                <img src={main.image ?? userProfile?.image} alt={main.title} class="w-full h-full object-cover rounded-xl" />
            </div>
        </div>
    </UserProfile>
{/if}