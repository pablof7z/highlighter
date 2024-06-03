<script lang="ts">
	import Highlight from '$components/Highlight.svelte';
	import MostHighlightedArticleGrid from "$components/MostHighlightedArticleGrid.svelte";
	import { computeArticleRecommendationFromHighlightStore } from "$utils/recommendations";
	import { ndk } from "$stores/ndk.js";
	import { NDKDVMJobResult, NDKEvent, NDKHighlight, NDKKind, NDKRelaySet, NDKSubscriptionCacheUsage, NostrEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from 'svelte';
	import FeaturedCreators from '$components/PageElements/FeaturedCreators.svelte';
	import Logo from '$icons/Logo.svelte';
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';
	import { NavigationOption } from '../../app';
	import FeaturedReads from '$components/PageElements/FeaturedReads.svelte';
	import { featuredCreatorsPerCategory } from "$utils/const";
	import { BookmarkSimple, GlobeStand, Link } from "phosphor-svelte";
	import { derived, writable } from "svelte/store";
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { layoutMode, pageHeader, pageNavigationOptions, resetLayout } from "$stores/layout";
	import { Card, Button, Page } from "konsta/svelte";
	import ArticleCard from "$components/ArticleCard.svelte";
    import { PageTransition } from 'sveltekit-page-transitions';
	import FeaturedItem from "$components/Card/FeaturedItem.svelte";
	import LoadEvent from "$components/Event/LoadEvent.svelte";
	import { appMobileHideNewPostButton, appMobileView } from "$stores/app";
	import FeaturedArticleList from "$components/Card/FeaturedArticleList.svelte";
	import LoadingScreen from "$components/LoadingScreen.svelte";
    import { register } from 'swiper/element/bundle';
	import currentUser from "$stores/currentUser";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import throttleStore from "$utils/stores/throttle";
	import HighlightBody from '$components/HighlightBody.svelte';
	import Swipe from '$components/Swipe.svelte';

    register();

    $layoutMode = "content-focused";

    const sinceOneHourAgo = Math.floor((Date.now() - 60 * 60) / 1000);

    let dvmReq: NDKEvent | undefined;
    let dvmResp: NDKEventStore<NDKDVMJobResult>;

    $: console.log('current user pubkey', $currentUser?.pubkey);

    $: if ($currentUser && dvmReq && !dvmResp && $ndk.signer) {
        console.log("Subscribing to DVM");
        dvmResp = $ndk.storeSubscribe({
            kinds: [6300 as number], "#p": [$currentUser.pubkey], since: sinceOneHourAgo,
        }, {
            onEose: () => {
                console.log("DVM response eose");
                if ($dvmResp.length === 0) {
                    console.log("No DVM response, sending DVM request");
                    dvmReq = new NDKEvent($ndk, {
                        kind: NDKKind.DVMReqDiscoveryNostrContent,
                        tags: [
                            ["p", "6b37d5dc88c1cbd32d75b713f6d4c2f7766276f51c9337af9d32c8d715cc1b93" ]
                        ]
                    } as NostrEvent)
                    dvmReq.publish();
                } else {
                    console.log("DVM response", $dvmResp.length);
                }
            }
        }, NDKDVMJobResult);
    }

    $appMobileHideNewPostButton = true;

    const allFeaturedPubkeys = Object.values(featuredCreatorsPerCategory).flat();

    const startTime = Date.now();
    const relaySet = NDKRelaySet.fromRelayUrls(["wss://relay.highlighter.com"], $ndk);
    const feed = $ndk.storeSubscribe([
        {kinds: [NDKKind.Highlight], authors: allFeaturedPubkeys, limit: 100 },
        {kinds: [NDKKind.Highlight], "#p": allFeaturedPubkeys, limit: 100 },
    ], {
        cacheUsage: NDKSubscriptionCacheUsage.PARALLEL,
        closeOnEose: true,
        groupable:
        false,
        relaySet
    }, NDKHighlight)

    let feedEosed = false;

    feed.onEose(() => {
        const endTime = Date.now();
        console.log("Feed eose, took", endTime - startTime, "ms");
        feedEosed = true;
    });

    // const events = $ndk.storeSubscribe([
    //     {kinds: [NDKKind.Subscribe], limit: 100},
    //     {kinds: [NDKKind.TierList], limit: 100},
    // ], { closeOnEose: true, groupable: false });

    onDestroy(() => {
        feed.unsubscribe();
        dvmResp?.unsubscribe();
        // events.unsubscribe();
        resetLayout();
    });

    let selectedFeaturedPubkeys: string[] = [];

    const highlightIsByFeaturedAuthor = (h: NDKHighlight) => selectedFeaturedPubkeys.includes(h.pubkey);
    const highlightTagsFeaturedAuthor = (h: NDKHighlight) => h.getMatchingTags("p").some(t => selectedFeaturedPubkeys.includes(t[1]));
    const highlightFilter = (h: NDKHighlight) => highlightIsByFeaturedAuthor(h) || highlightTagsFeaturedAuthor(h);

    const mainCategories: NavigationOption[] = Object.keys(featuredCreatorsPerCategory).map(category => ({ name: category, value: category }));
    mainCategories.unshift({ name: 'All Topics', value: 'All Topics', icon: GlobeStand });

    let category = mainCategories[0].value!;
    const categoryStore = writable<string>(category);

    $: categoryStore.set(category);

    $: if (category === 'All Topics') {
        selectedFeaturedPubkeys = allFeaturedPubkeys;
    } else {
        selectedFeaturedPubkeys = featuredCreatorsPerCategory[category];
    }

    const filteredFeed = derived([feed, categoryStore], ([$feed, $categoryStore]) => {
        if ($categoryStore === 'All Topics') return $feed;

        return $feed.filter(highlightFilter);
    })

    const recommendedArticles = computeArticleRecommendationFromHighlightStore(filteredFeed);

    const articles = derived(recommendedArticles, ($recommendedArticles) => {
        return $recommendedArticles.filter(({tag}) => tag[0] === "a");
    });

    const throttledArticles = throttleStore(articles, 1000);

    $pageHeader = {
        // component: HorizontalOptionsList,
        title: 'Highlighter',
        // props: {
        //     options: mainCategories,
        //     class: "py-4",
        //     bind: { value: category }
        // },
        subNavbarOptions: mainCategories,
        subNavbarValue: 'All Topics',
    }
</script>
<LoadingScreen ready={true}>
    {#if $appMobileView}
    <swiper-container
        direction="vertical"
        freemode="true"
        mousewheel="true"
        pagination="true"
    >
        <swiper-slide>
            <div class="grid grid-rows-3 grid-flow-row h-full w-full">
                <div class="flex grow w-full">
                    {#if $throttledArticles[0]?.tag}
                        <FeaturedReads articleTag={$throttledArticles[0].tag} highlights={$throttledArticles[0].highlights} />
                    {/if}
                </div>
                <div class="flex w-full">
                    {#if $throttledArticles[1]?.tag}
                        <FeaturedReads articleTag={$throttledArticles[1].tag} highlights={$throttledArticles[1].highlights} />
                    {/if}
                </div>
                <div class="flex w-full">
                    {#if $throttledArticles[2]?.tag}
                        <FeaturedReads articleTag={$throttledArticles[2].tag} highlights={$throttledArticles[2].highlights} />
                    {/if}
                </div>
            </div>
        </swiper-slide>
        <swiper-slide>
            <div class="grid grid-rows-2 w-full max-h-[85vh]">
                {#if $throttledArticles[3]?.tag}
                    <div class="flex w-full">
                        <Swipe
                            class="flex w-full h-full"
                            rightOptions={[
                                { label: 'Read Later', icon: BookmarkSimple, class: "bg-white/20 !text-red-500", cb: ()=>{} },
                            ]}
                        >
                            <FeaturedReads articleTag={$throttledArticles[3].tag} highlights={$throttledArticles[3].highlights} />
                        </Swipe>
                    </div>
                    <swiper-container class="!h-auto shrink basis-0 overflow-auto scrollbar-hide" direction="horizontal">
                        {#each $throttledArticles[3].highlights as highlight (highlight.id)}
                            <swiper-slide>
                                <Card class="w-full">
                                    <HighlightBody
                                        {highlight}
                                        skipArticle={true}
                                        skipHighlighter={false}
                                    />
                                </Card>
                            </swiper-slide>
                        {/each}
                    </swiper-container>
                    
                    <!-- <LoadEvent tag={$throttledArticles[3].tag} let:article let:authorUrl let:userProfile>
                        {#if article}
                        {/if}
                    </LoadEvent> -->
                {/if}
            </div>
        </swiper-slide>
        <swiper-slide>
            <div class="flex w-full">
                {#if $throttledArticles[4]?.tag}
                    <LoadEvent tag={$throttledArticles[4].tag} let:article let:authorUrl let:userProfile>
                        {#if article}
                            <FeaturedItem
                                {article}
                                highlights={$throttledArticles[4].highlights}
                                {authorUrl}
                                {userProfile}
                            />
                        {/if}
                    </LoadEvent>
                {/if}
            </div>
        </swiper-slide>
        <swiper-slide>
            <div class="flex overflow-y-auto scrollbar-hide max-h-[90vh]">
                <LoadEvent
                    id="naddr1qvzqqqr4xspzq0ycfyurhh4gswct69h7ec0dxmfhud7dmc7wgwchaf8fryhvzy5fqythwumn8ghj7un9d3shjtnwdaehgu3wvfskuep0qqgxgc3exg6rwv35xuur2v34xcek2kcc6th"
                    let:articleList
                    let:authorUrl
                    let:userProfile
                >
                    {#if articleList}
                        <FeaturedArticleList {articleList} {authorUrl} {userProfile} />
                    {/if}
                </LoadEvent>
            </div>
        </swiper-slide>
        <swiper-slide>
            <div class="flex flex-col overflow-y-auto scrollbar-hide max-h-[90vh]">
                <h1 class="text-white">Notes you missed</h1>
                {#if $dvmResp?.[0] && $dvmResp[0].result}
                    {#each JSON.parse($dvmResp[0].result).slice(0, ) as tag}
                        <LoadEvent tag={tag} let:event let:authorUrl let:userProfile>
                            {#if event}
                                <EventWrapper {event} {authorUrl} {userProfile} />
                            {/if}
                        </LoadEvent>
                    {/each}
                    <a href="#" class="text-accent text-sm">View all</a>
                {/if}
            </div>
        </swiper-slide>
    </swiper-container>
    {:else}
    <main>
    <section>
        <div class="grid grid-rows-3 grid-flow-row h-full w-full">
            <div class="flex grow w-full">
                {#if $throttledArticles[0]?.tag}
                    <FeaturedReads articleTag={$throttledArticles[0].tag} highlights={$throttledArticles[0].highlights} />
                {/if}
            </div>
            <div class="flex w-full">
                {#if $throttledArticles[1]?.tag}
                    <FeaturedReads articleTag={$throttledArticles[1].tag} highlights={$throttledArticles[1].highlights} />
                {/if}
            </div>
            <div class="flex w-full">
                {#if $throttledArticles[2]?.tag}
                    <FeaturedReads articleTag={$throttledArticles[2].tag} highlights={$throttledArticles[2].highlights} />
                {/if}
            </div>
        </div>
    </section>
    <section>
        <div class="grid grid-rows-2 w-full max-h-[85vh]">
            {#if $throttledArticles[3]?.tag}
                <div class="flex w-full">
                    <Swipe
                        class="flex w-full h-full"
                        rightOptions={[
                            { label: 'Read Later', icon: BookmarkSimple, class: "bg-white/20 !text-red-500", cb: ()=>{} },
                        ]}
                    >
                        <FeaturedReads articleTag={$throttledArticles[3].tag} highlights={$throttledArticles[3].highlights} />
                    </Swipe>
                </div>
                <swiper-container class="!h-auto shrink basis-0 overflow-auto scrollbar-hide" direction="horizontal">
                    {#each $throttledArticles[3].highlights as highlight (highlight.id)}
                        <section>
                            <Card class="w-full">
                                <HighlightBody
                                    {highlight}
                                    skipArticle={true}
                                    skipHighlighter={false}
                                />
                            </Card>
                        </section>
                    {/each}
                </swiper-container>
                
                <!-- <LoadEvent tag={$throttledArticles[3].tag} let:article let:authorUrl let:userProfile>
                    {#if article}
                    {/if}
                </LoadEvent> -->
            {/if}
        </div>
    </section>
    <section>
        <div class="flex w-full">
            {#if $throttledArticles[4]?.tag}
                <LoadEvent tag={$throttledArticles[4].tag} let:article let:authorUrl let:userProfile>
                    {#if article}
                        <FeaturedItem
                            {article}
                            highlights={$throttledArticles[4].highlights}
                            {authorUrl}
                            {userProfile}
                        />
                    {/if}
                </LoadEvent>
            {/if}
        </div>
    </section>
    <section>
        <div class="flex overflow-y-auto scrollbar-hide max-h-[90vh]">
            <LoadEvent
                id="naddr1qvzqqqr4xspzq0ycfyurhh4gswct69h7ec0dxmfhud7dmc7wgwchaf8fryhvzy5fqythwumn8ghj7un9d3shjtnwdaehgu3wvfskuep0qqgxgc3exg6rwv35xuur2v34xcek2kcc6th"
                let:articleList
                let:authorUrl
                let:userProfile
            >
                {#if articleList}
                    <FeaturedArticleList {articleList} {authorUrl} {userProfile} />
                {/if}
            </LoadEvent>
        </div>
    </section>
    <section>
        <div class="flex flex-col overflow-y-auto scrollbar-hide max-h-[90vh]">
            <h1 class="text-white">Notes you missed</h1>
            {#if $dvmResp?.[0] && $dvmResp[0].result}
                {#each JSON.parse($dvmResp[0].result).slice(0, ) as tag}
                    <LoadEvent tag={tag} let:event let:authorUrl let:userProfile>
                        {#if event}
                            <EventWrapper {event} {authorUrl} {userProfile} />
                        {/if}
                    </LoadEvent>
                {/each}
                <a href="#" class="text-accent text-sm">View all</a>
            {/if}
        </div>
    </section>
</main>
    {/if}

</LoadingScreen>

<!-- <h1 class="text-white font-medium text-7xl">
    Discover your next guilty pleasure
</h1> -->

<!-- background-image: radial-gradient(56.1514% 56.1514% at 49.972% 38.959%, rgb(39, 54, 73) 0%, rgb(0, 0, 0) 100%); -->
<!-- 
<div class="min-h-[70vh] max-sm:hidden">
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
</div> -->
<!-- 
<div class="hidden">
    <div class="sticky top-0 h-[4rem] bg-base-200/70 backdrop-blur-xl z-50 max-sm:hidden">
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

<section class=" bg-base-300 !text-white min-h-screen flex items-center justify-center !hidden">
    <div class="max-w-7xl mx-auto sticky top-0">
        <header class="flex flex-col gap-10">
            <h1 class="text-7xl">
                Are you a content
                <span class="border-b-8 border-accent">creator</span>?
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
                
                <a href="#" class="button text-xl bg-base-100 text-base-100-content font-medium p-4 border-4 border-accent px-8">
                    how Nostr helps grow your reach
                </a>
            </div>
            
        </header>
    </div>
</section> -->

<style lang="postcss">
    section {
        @apply min-h-screen flex flex-col gap-8 py-10;
    }

    section header {
        @apply my-24;
        @apply flex flex-col items-start;
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
        @apply text-accent font-medium;
    }

    swiper-container {
        display: flex;
        width: 100%;
        /* height: 100%; */
        height: 90vh;
    }

    swiper-slide {
        display: flex;
        justify-content: center;
        /* align-items: center; */
        width: 100%;
        height: 100%;
        @apply overflow-y-auto;
        scrollbar-width: none;
        -ms-overflow-style: none;
    }
</style>