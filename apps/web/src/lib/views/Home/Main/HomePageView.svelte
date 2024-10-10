<script lang="ts">
	import { onDestroy } from 'svelte';
	import { wotFilteredStore } from '$stores/wot';
	import { NDKHighlight, NDKKind, NDKRelaySet, NDKVideo, NDKSimpleGroupMetadata } from '@nostr-dev-kit/ndk';
	
	import { ndk } from "$stores/ndk";
	import { userFollows } from "$stores/session";
	import { derived, Readable } from "svelte/store";
    import * as Card from '$components/Card';
    import Footer from "./Footer.svelte";
	import HorizontalListOfTaggedItems from '$components/PageElements/Sections/HorizontalListOfTaggedItems.svelte';
	import { layout } from '$stores/layout';
	import { vanityUrls } from '$utils/const';
	import Groups from '../Sections/Groups.svelte';
	import Reads from './Sections/Reads.svelte';
	import ReadsSidebar from './Sections/ReadsSidebar.svelte';

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

    // const relaySet = NDKRelaySet.fromRelayUrls([ "ws://localhost:2929" ], $ndk);
    // const groups = $ndk.storeSubscribe({ kinds: [NDKKind.GroupMetadata] }, { relaySet }, NDKSimpleGroupMetadata);

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
    
    onDestroy(() => {
        // groups.unsubscribe();
        highlights.unsubscribe();

    })
</script>

<div class="flex flex-col sm:gap-[var(--section-vertical-padding)] mx-auto w-full">
    <!-- <ul class="w-1/3 border-x overflow-clip flex flex-col divide-y">
        {#each $groups as group}
            <li
                class="h-40 rounded"
            >
                <img src={group.picture} />
                <div class="text-lg font-medium">{group.name}</div>
                {group.about}
            </li>
        {/each}
    </ul> -->
    <!-- <Groups /> -->
    
    <div class="flex flex-col-reverse items-start gap-6">
        <div class="w-full lg:w-[var(--content-focused-width)] mx-auto">
            <Reads />
        </div>

        <!-- <div class="hidden md:flex flex-row h-full gap-4">
            <ReadsSidebar />
        </div> -->
    </div>

</div>