<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import Article from './../../../components/Grid/Article.svelte';
	import { wotFilteredStore } from '$stores/wot';
	import { NDKArticle, NDKEvent, NDKHighlight, NDKKind } from '@nostr-dev-kit/ndk';
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	
    import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import Avatar from "$components/User/Avatar.svelte";
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
	import { layout, layoutMode, pageHeader } from '$stores/layout';
	import { appMobileView } from '$stores/app';
	import StoriesFeed from '$components/PageElements/StoriesFeed.svelte';
	import { NavigationOption } from '../../../../app';
	import LayoutHeaderNavigation from '$components/Layout/Headers/LayoutHeaderNavigation.svelte';
	import HomePageSidebar from './HomePageSidebar.svelte';

    $layoutMode = "full-width";

    const articles = $ndk.storeSubscribe({
        kinds: [NDKKind.Article], authors: Array.from($userFollows), limit: 50
    }, undefined, NDKArticle);
    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;
    const filteredArticles = derived(wotF, ($wotF) => {
        return filterArticle(wotF);
    });

    $pageHeader.footer = {
        component: Footer,
        props: {}
    }

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
        header: {
            component: LayoutHeaderNavigation,
        },
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

