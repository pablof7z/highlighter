<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { wotFilteredStore } from '$stores/wot';
	import { NDKArticle, NDKHighlight, NDKKind, NDKVideo } from '@nostr-dev-kit/ndk';
	
	import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { derived, Readable } from "svelte/store";
	import { filterArticles } from '$utils/article-filter';
    import * as Card from '$components/Card';
    import Footer from "./Footer.svelte";
	import HorizontalListOfTaggedItems from '$components/PageElements/Sections/HorizontalListOfTaggedItems.svelte';
	import { layout } from '$stores/layout';
	import { vanityUrls } from '$utils/const';
	import Groups from '../Sections/Groups.svelte';
	import Sidebar from './Sidebar.svelte';
	import Reads from './Sections/Reads.svelte';

    $layout.fullWidth = true;

    const articles = $ndk.storeSubscribe({
        kinds: [NDKKind.Article], limit: 50
    }, undefined, NDKArticle);
    const wotF = wotFilteredStore(articles) as Readable<NDKArticle[]>;
    const filteredArticles = filterArticles(wotF);

    const videos = $ndk.storeSubscribe([
        { kinds: [NDKKind.HorizontalVideo, NDKKind.HorizontalVideo+1], authors: Array.from($userFollows), limit: 50 },
        { kinds: [NDKKind.HorizontalVideo], authors: Array.from($userFollows), limit: 50 },
    ], undefined, NDKVideo);
    const filteredVideos = wotFilteredStore(videos) as Readable<NDKVideo[]>;

    let highlightsEosed = false;
    const highlights = $ndk.storeSubscribe([
        {kinds: [NDKKind.Highlight], limit: 50},
        {kinds: [NDKKind.Highlight], authors: Array.from($userFollows), limit: 150},
    ], {
        onEose: () => { highlightsEosed = true; }
    }, NDKHighlight);

    const followHighlights = derived(highlights, $highlights => {
        return $highlights.filter(highlight => $userFollows.has(highlight.pubkey));
    });

    $layout = {
        sidebar: {
            component: Sidebar,
        },
        footer: {
            component: Footer,
            props: {}
        }
    }

    const featuredUsers = Array.from(
            new Set(Object.values(vanityUrls))
        ).map(pubkey => $ndk.getUser({ pubkey }))
        .map(user => { return { user, id: user.pubkey } });
</script>

<div class="flex flex-col gap-[var(--section-vertical-padding)]">
    <Groups />

    <Reads />

    <!-- <HorizontalList title="Articles" items={$filteredArticles} let:item>
        <Card.Article article={item} />
    </HorizontalList> -->

    <HorizontalList title="Featured Creators" items={featuredUsers} let:item>
        <Card.User user={item.user} />
    </HorizontalList>

    {#if highlightsEosed}
        <HorizontalListOfTaggedItems title="Reads" highlights={followHighlights} />
    {/if}

    <HorizontalList title="Highlights" items={$highlights} let:item>
        <Card.Highlight highlight={item} />
    </HorizontalList>

</div>