<script lang="ts">
	import HorizontalList from '$components/PageElements/HorizontalList';
	import { wotFilteredStore } from '$stores/wot';
	import { NDKArticle, NDKHighlight, NDKKind, NDKList, NDKSimpleGroup, NDKVideo } from '@nostr-dev-kit/ndk';
	
	import { ndk } from "$stores/ndk";
	import { groupsList, userFollows } from "$stores/session";
	import { derived, Readable } from "svelte/store";
	import { filterArticles } from '$utils/article-filter';
    import * as Card from '$components/Card';
    import Footer from "./Footer.svelte";
	import HorizontalListOfTaggedItems from '$components/PageElements/Sections/HorizontalListOfTaggedItems.svelte';
	import { layout } from '$stores/layout';
	import HomePageSidebar from './HomePageSidebar.svelte';
	import { vanityUrls } from '$utils/const';
    import * as Chat from '$components/Chat';

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

    const filteredHighlights = wotFilteredStore<NDKHighlight>(highlights);
    const followHighlights = derived(highlights, $highlights => {
        return $highlights.filter(highlight => $userFollows.has(highlight.pubkey));
    });

    const followGroups = $ndk.storeSubscribe([
        { kinds: [ NDKKind.SimpleGroupList ], authors: Array.from($userFollows) }
    ], undefined, NDKList);
    const groupsByCount = derived(followGroups, $followGroups => {
        const groups: Record<string, number> = {};
        const groupRelays: Record<string, string> = {};

        for (const list of $followGroups) {
            for (const item of list.items) {
                if (item[0] !== "group" || !item[1] && !item[2]) continue;

                const groupId = item[1];
                groups[groupId] = (groups[groupId] || 0) + 1;
                groupRelays[groupId] = item[2];
            }
        }

        // sort
        return Object.entries(groups)
            .sort((a, b) => b[1] - a[1])
            .map(([groupId, count]) => [ groupId, groupRelays[groupId] ]);
    });

    $layout = {
        sidebar: {
            component: HomePageSidebar
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

{#if $groupsList && $groupsList.items.length > 0}
    <Chat.List>
        {#each $groupsList.items as group (group[1])}
            <Chat.Item tag={["group", group[1], group[2]]} />
        {/each}
    </Chat.List>
{/if}

<HorizontalList title="Featured Creators" items={featuredUsers} let:item>
    <Card.User user={item.user} />
</HorizontalList>

<HorizontalList title="Articles" items={$filteredArticles} let:item>
    <Card.Article article={item} />
</HorizontalList>

<HorizontalList title="Videos" items={$filteredVideos} let:item>
    <Card.Video video={item} />
</HorizontalList>

{#if highlightsEosed}
    <HorizontalListOfTaggedItems title="Reads" highlights={followHighlights} />
{/if}

<HorizontalList title="Highlights" items={$highlights} let:item>
    <Card.Highlight highlight={item} />
</HorizontalList>

