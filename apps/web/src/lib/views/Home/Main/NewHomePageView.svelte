<script lang="ts">
	import Article from './../../../components/Grid/Article.svelte';
	import { wotFilteredStore } from '$stores/wot';
	import { NDKArticle, NDKEvent, NDKHighlight, NDKKind } from '@nostr-dev-kit/ndk';
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import HorizontalList from "$components/PageElements/HorizontalList";
    import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import Avatar from "$components/User/Avatar.svelte";
	import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { derived, Readable, writable } from "svelte/store";
	import { filterArticle } from '$utils/article-filter';
	import HighlightBody from '$components/HighlightBody.svelte';
	import { openModal } from '$utils/modal';
	import StoryModal from '$modals/StoryModal.svelte';
	import ArticleGridArticle from '$components/ArticleGridArticle.svelte';
    import Footer from "$components/PageElements/Mobile/Footer.svelte";
	import ArticleGridUrlItem from '$components/ArticleGridUrlItem.svelte';
	import HorizontalListOfTaggedItems from '$components/PageElements/Sections/HorizontalListOfTaggedItems.svelte';
	import { pageHeader } from '$stores/layout';

    const articles = $ndk.storeSubscribe({
        kinds: [NDKKind.Article], authors: Array.from($userFollows), limit: 50
    }, undefined, NDKArticle);
    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;
    const filteredArticles = derived(wotF, ($wotF) => {
        return filterArticle(wotF);
    });

    $pageHeader ??= {};
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

    const twentyfourhoursago = Math.floor(Date.now() / 1000) - 864000;

    const videos = $ndk.storeSubscribe([
        { kinds: [1063], authors: Array.from($userFollows), limit: 100, "#m": ["video/mp4"], since: twentyfourhoursago },
        { kinds: [1063], limit: 100, "#m": ["video/mp4"], since: twentyfourhoursago },
        { kinds: [NDKKind.HorizontalVideo+1], limit: 100, since: twentyfourhoursago },
    ])
    const filteredVideos = derived(wotFilteredStore(videos), ($videos) => {
        return $videos.filter(video => video.tagValue("url"));
    });

    const photos = $ndk.storeSubscribe([
        { kinds: [1063], authors: Array.from($userFollows), limit: 10, "#m": ["image/jpeg"] }
    ])

    const pubkeysWithVideos = derived(filteredVideos, ($filteredVideos) => {
        return Array.from(new Set($filteredVideos.map(video => video.pubkey)))
            .map(pubkey => { return {id: pubkey, pubkey}; })
    });
</script>

<HorizontalList items={$pubkeysWithVideos} let:item>
    <button on:click={() => openModal(StoryModal, { pubkey: item.pubkey })} class="py-1">
        <Avatar pubkey={item.pubkey} class="w-14 h-14" ring />
    </button>
</HorizontalList>

<ScrollArea class="whitespace-nowrap border-y border-border py-4" orientation="horizontal">
    <HorizontalOptionsList options={[
        { name: "Home", href: "/" },
        { name: "Reads", href: "/reads" },
        { name: "Communities", href: '/chat' },
        { name: "Posts", href: '/notes' },
        { name: "Wiki", href: '/wiki' },
    ]} class="px-4" />
</ScrollArea>

<!--
<HorizontalList title="Articles" items={$filteredArticles} let:item>
    <ArticleGridArticle article={item} />
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
 -->
