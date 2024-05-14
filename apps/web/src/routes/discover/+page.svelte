<script lang="ts">
	import MostHighlightedArticleGrid from "$components/MostHighlightedArticleGrid.svelte";
	import { computeArticleRecommendationFromHighlightStore } from "$utils/recommendations";
	import { ndk } from "@kind0/ui-common";
	import { NDKHighlight, NDKKind } from "@nostr-dev-kit/ndk";
	import { onDestroy } from 'svelte';
	import FeaturedCreators from '$components/PageElements/FeaturedCreators.svelte';
	import Logo from '$icons/Logo.svelte';
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';
	import { NavigationOption } from '../../app';
	import FeaturedReads from '$components/PageElements/FeaturedReads.svelte';
	import { featuredCreatorsPerCategory } from "$utils/const";
	import { GlobeStand } from "phosphor-svelte";
	import { derived, writable } from "svelte/store";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";

    const allFeaturedPubkeys = Object.values(featuredCreatorsPerCategory).flat();

    const feed = $ndk.storeSubscribe([
        {kinds: [NDKKind.Highlight], authors: allFeaturedPubkeys, limit: 100 },
        {kinds: [NDKKind.Highlight], "#p": allFeaturedPubkeys, limit: 100 },
    ], { closeOnEose: true }, NDKHighlight)

    const events = $ndk.storeSubscribe([
        {kinds: [NDKKind.Subscribe], limit: 100},
        {kinds: [NDKKind.TierList], limit: 100},
    ], { closeOnEose: true });

    onDestroy(() => {
        events.unsubscribe();
    });

    let selectedFeaturedPubkeys: string[] = [];

    const highlightIsByFeaturedAuthor = (h: NDKHighlight) => selectedFeaturedPubkeys.includes(h.pubkey);
    const highlightTagsFeaturedAuthor = (h: NDKHighlight) => h.getMatchingTags("p").some(t => selectedFeaturedPubkeys.includes(t[1]));
    const highlightFilter = (h: NDKHighlight) => highlightIsByFeaturedAuthor(h) || highlightTagsFeaturedAuthor(h);

    const mainCategories: NavigationOption[] = Object.keys(featuredCreatorsPerCategory).map(category => ({ name: category, value: category }));
    mainCategories.unshift({ name: 'All Topics', value: 'all', icon: GlobeStand });

    let category = mainCategories[0].value!;
    const categoryStore = writable<string>(category);

    $: categoryStore.set(category);

    $: if (category === 'all') {
        selectedFeaturedPubkeys = allFeaturedPubkeys;
    } else {
        selectedFeaturedPubkeys = featuredCreatorsPerCategory[category];
    }

    const filteredFeed = derived([feed, categoryStore], ([$feed, $categoryStore]) => {
        if ($categoryStore === 'all') return $feed;

        return $feed.filter(highlightFilter);
    })

    const recommendedArticles = computeArticleRecommendationFromHighlightStore(filteredFeed);

    const articles = derived(recommendedArticles, ($recommendedArticles) => {
        return $recommendedArticles.filter(({tag}) => tag[0] === "a");
    });
</script>

<!-- <h1 class="text-white font-medium text-7xl">
    Discover your next guilty pleasure
</h1> -->

<!-- background-image: radial-gradient(56.1514% 56.1514% at 49.972% 38.959%, rgb(39, 54, 73) 0%, rgb(0, 0, 0) 100%); -->

<div class="min-h-[70vh]">
    <div class="max-w-7xl mx-auto flex flex-col gap-8 py-10">
        <Logo class="w-52 text-base-100-content opacity-80" />
        <div class="flex flex-col gap-6">
            <h1 class="text-7xl font-semibold text-white leading-[80px]">
                Discover content
                <span class="accent">you want</span>,
                from creators
                <span class="accent">you care about</span>.
            </h1>

            <h2 class="text-5xl font-light text-white leading-[80px]">
                Zero intermediaries.
            </h2>
        </div>
    </div>
</div>

<div>
    <div class="sticky top-0 h-[4rem] bg-base-200/70 backdrop-blur-xl z-50">
        <div class="max-w-7xl mx-auto flex flex-row items-center text-xl">
            <HorizontalOptionsList
                options={mainCategories}
                class="py-4"
                bind:value={category}
            />
        </div>
    </div>
    <section>
        <div class="max-w-7xl mx-auto">
            <header>
                <h1 class="">
                    <span class="accent !font-bold">
                        Read.
                    </span>
                </h1>
                <h2>
                    Discover what your friends are reading.
                </h2>
            </header>
        
            {#if category === "all"}
                <WithItem tagId="naddr1qqxnzd3exsmrswfjxsurxvf3qgsxu35yyt0mwjjh8pcz4zprhxegz69t4wr9t74vk6zne58wzh0waycrqsqqqa2844arph" let:article>
                    <FeaturedReads {article} highlights={[]} />
                </WithItem> 
            {:else}
                {#key $articles[0].tag[1]}
                    {$articles[0].tag[1]}
                    <FeaturedReads articleTag={$articles[0].tag} highlights={$articles[0].highlights} />
                {/key}
            {/if}

        <div class="divider my-10"></div>

        {$feed.length}
        {$filteredFeed.length}

        <MostHighlightedArticleGrid articleTagsWithHighlights={$articles.slice(1, -1)} />
        </div>
    </section>

    <section>
        <div class="max-w-7xl mx-auto w-full">
            <h1 class="text-7xl sticky top-[4rem] z-50 w-full bg-base-100 py-2 h-[7rem] flex items-center bg-base-200/70 backdrop-blur-xl z-50">
                <span class="gradient-text">
                    Discover: creators you love
                </span>
            </h1>
    
            <FeaturedCreators {category} />
        </div>
    </section>
</div>

<section class=" bg-base-300 !text-white min-h-screen flex items-center justify-center">
    <div class="max-w-7xl mx-auto sticky top-0">
        <header class="flex flex-col gap-10">
            <h1 class="text-7xl">
                Are you a content
                <span class="border-b-8 border-accent2">creator</span>?
            </h1>
            
            <div class="flex flex-row gap-10">
                <h2>
                    Nostr brings an entirely new approach to content
                    <span class="accent">monetization</span>,
                    and particularly
                    <span class="accent">distribution</span>.
                </h2>
    
                <h2>
                    If you've ever struggled with reaching a wider audience,
                    prefer focusing on creating rather than marketing,
                    read about how nostr can help.
                </h2>
            </div>

            <div class="flex flex-row gap-10 font-medium justify-center my-10">
                <button class="button text-xl button-primary px-10">
                    Get started
                </button>
                
                <a href="#" class="button text-xl bg-base-100 text-base-100-content font-medium p-4 border-4 border-accent2 px-8">
                    how Nostr helps grow your reach
                </a>
            </div>
            
        </header>
    </div>
</section>

<style lang="postcss">
    section {
        @apply min-h-screen flex flex-col gap-8 py-10;
    }

    section header {
        @apply my-24;
        @apply flex flex-col items-start;
    }

    section .container {
        @apply max-w-7xl mx-auto;
    }

    section header h1 {
        @apply text-7xl font-semibold mb-0;
    }

    section header h2 {
        @apply text-3xl font-light text-white;
    }

    section .header > h3 {
        @apply text-2xl font-normal opacity-60;
    }

    span.accent {
        @apply text-accent2 font-medium;
    }
</style>