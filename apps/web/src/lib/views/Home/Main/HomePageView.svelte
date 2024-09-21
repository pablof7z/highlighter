<script lang="ts">
	import { wotFilteredStore } from '$stores/wot';
	import { NDKArticle, NDKHighlight, NDKKind, NDKVideo } from '@nostr-dev-kit/ndk';
	
	import { ndk } from "$stores/ndk";
	import { groupsList, userFollows } from "$stores/session";
	import { derived, Readable } from "svelte/store";
    import * as Card from '$components/Card';
    import Footer from "./Footer.svelte";
	import HorizontalListOfTaggedItems from '$components/PageElements/Sections/HorizontalListOfTaggedItems.svelte';
	import { layout } from '$stores/layout';
	import { vanityUrls } from '$utils/const';
	import Groups from '../Sections/Groups.svelte';
	import Reads from './Sections/Reads.svelte';
	import ReadsSidebar from './Sections/ReadsSidebar.svelte';
	import Generic from '$components/Groups/Sidebar/Generic.svelte';
	import Header from './Header.svelte';
	import { NavigationOption } from '../../../../app';
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';

    $layout.navigation = [
        { value: "", name: "👋 Newest", href: '/reads' },
        { name: "🌟 Top", href: '/reads/top' },
        // { name: "🔥 Hot", href: '/reads/hot' },
        { name: "🖊️ Highlighted", href: '/reads/highlighted' },
        { name: "📚 Curations", href: '/reads/curations' },
        // { name: "Feed Marketplace", icon: Plus, buttonProps: { class: 'place-self-end', variant: 'secondary' }, href: '/reads/dvms' },
    ]

    $layout.activeOption = $layout.navigation[0];

    $layout.title = undefined;
    $layout.fullWidth = true;
    // $: $layout.sidebar = $groupsList && $groupsList.items.length > 0 ? { component: Generic } : false;
    $layout.sidebar = false;
    $layout.forceShowNavigation = true;

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

    const featuredUsers = Array.from(
            new Set(Object.values(vanityUrls))
        ).map(pubkey => $ndk.getUser({ pubkey }))
        .map(user => { return { user, id: user.pubkey } });
</script>

<div class="flex flex-col sm:gap-[var(--section-vertical-padding)] mx-auto w-fit lg:px-6">
    <!-- <Groups /> -->
    
    <div class="flex flex-row items-start gap-6 w-full">
        <div class="w-full lg:w-[var(--content-focused-width)]">
            <Reads />
        </div>

        <div class="hidden md:flex flex-col w-[260px] h-full">
            <ReadsSidebar />
        </div>
    </div>

</div>