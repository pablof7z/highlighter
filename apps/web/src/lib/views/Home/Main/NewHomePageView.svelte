<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { wotFilteredStore } from '$stores/wot';
	import { NDKArticle, NDKEvent, NDKHighlight, NDKKind, NDKVideo } from '@nostr-dev-kit/ndk';
	
	import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { derived, Readable, writable } from "svelte/store";
	import { filterArticle } from '$utils/article-filter';
	import HighlightBody from '$components/HighlightBody.svelte';
	import { openModal } from '$utils/modal';
	import StoryModal from '$modals/StoryModal.svelte';
    import * as Card from '$components/Card';
    import Footer from "$components/PageElements/Mobile/Footer.svelte";
	import ArticleGridUrlItem from '$components/ArticleGridUrlItem.svelte';
	import HorizontalListOfTaggedItems from '$components/PageElements/Sections/HorizontalListOfTaggedItems.svelte';
	import { layout, layoutMode } from '$stores/layout';
	import { appMobileView } from '$stores/app';
	import StoriesFeed from '$components/PageElements/StoriesFeed.svelte';
	import { NavigationOption } from '../../../../app';
	import LayoutHeaderNavigation from '$components/Layout/Headers/LayoutHeaderNavigation.svelte';
	import HomePageSidebar from './HomePageSidebar.svelte';

    $layoutMode = "full-width";

    const articles = $ndk.storeSubscribe({
        kinds: [NDKKind.Article], limit: 50
    }, undefined, NDKArticle);
    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;
    const filteredArticles = derived(wotF, ($wotF) => {
        return filterArticle(wotF);
    });

    const videos = $ndk.storeSubscribe([
        { kinds: [NDKKind.HorizontalVideo, NDKKind.HorizontalVideo+1], authors: Array.from($userFollows), limit: 50 },
        { kinds: [NDKKind.HorizontalVideo], authors: Array.from($userFollows), limit: 50 },
    ], undefined, NDKVideo);
    const filteredVideos = wotFilteredStore(articles) as Readable<NDKArticle[]>;

    let highlightsEosed = false;
    const highlights = $ndk.storeSubscribe([
        {kinds: [NDKKind.Highlight], limit: 50},
        {kinds: [NDKKind.Highlight], authors: Array.from($userFollows), limit: 150},
    ], {
        groupable: false,
        onEose: () => { highlightsEosed = true; }
    }, NDKHighlight);

    const filteredHighlights = wotFilteredStore<NDKHighlight>(highlights);
    const followHighlights = derived(highlights, $highlights => {
        return $highlights.filter(highlight => $userFollows.has(highlight.pubkey));
    });

    const photos = $ndk.storeSubscribe([
        { kinds: [1063], authors: Array.from($userFollows), limit: 10, "#m": ["image/jpeg"] }
    ])

    $layout = {
        sidebar: {
            component: HomePageSidebar
        },
        footer: {
            component: Footer,
            props: {}
        }
    }
</script>

<HorizontalList title="Articles" items={$filteredArticles} let:item>
    <Card.Article article={item} />
</HorizontalList>

<HorizontalList title="Videos" items={$filteredVideos} let:item>
    <Card.Video video={item} />
</HorizontalList>

{#if highlightsEosed}
    <HorizontalListOfTaggedItems title="Reads" highlights={followHighlights} />
{/if}

<HorizontalList title="Photos" items={$photos} let:item>
    <img src={item.tagValue("url")} class="w-auto h-32 object-cover" />
</HorizontalList>

<HorizontalList title="Highlights" items={$highlights} let:item>
    <div class="w-64 whitespace-normal">
        <HighlightBody highlight={item} />
    </div>
</HorizontalList>

