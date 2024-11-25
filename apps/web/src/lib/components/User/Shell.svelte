<script lang="ts">
	import { NDKKind, NDKUser, NDKList, NDKHighlight, NDKEvent, NDKArticle, NDKVideo, NDKUserProfile, NDKSubscriptionTier, NDKSimpleGroup, NDKRelaySet, NDKTag, NDKSimpleGroupMetadata, NDKCashuMintList } from "@nostr-dev-kit/ndk";
	import { derived, get, Readable, writable } from "svelte/store";
	import { setContext } from "svelte";
	import { layout } from '$stores/layout';
	import type { NavigationOption } from '../../../app';
	import { getUserUrl } from "$utils/url";
	import { addHistory } from "$stores/history";
	import { page } from "$app/stores";
    import {Navigation} from "$utils/navigation";
    import UserHeader from "./Header.svelte";
	import { House } from "phosphor-svelte";
	import { roundedItemCount } from "$utils/numbers";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | undefined | null;
    export let authorUrl: string | undefined;
    export let fetching: boolean | undefined;
    export let highlights: Readable<NDKHighlight[]>;
    export let curations: Readable<NDKList[]>;
    export let notes: Readable<NDKEvent[]>;
    export let articles: Readable<NDKArticle[]>;
    export let cashuMintList: Readable<NDKCashuMintList | undefined>;
    export let videos: Readable<NDKVideo[]>;
    export let groupsList: Readable<NDKList | undefined>;
    export let pinList: Readable<NDKList | undefined>;
    export let tierList: Readable<NDKList | undefined>;
    export let allTiers: Readable<NDKSubscriptionTier[]>;
    export let tiers: Readable<NDKSubscriptionTier[]>;

    export let eosed: boolean | undefined = false;

    setContext('user', user);
    setContext('userNotes', notes);
    setContext('userHighlights', highlights);
    setContext('userCurations', curations);
    setContext('userArticles', articles);
    setContext('userVideos', videos);
    setContext('cashuMintList', cashuMintList);
    setContext('userGroupsList', groupsList);
    setContext('userPinList', pinList);
    setContext('userTierList', tierList);
    setContext('userTiers', tiers);

    let addedToHistory = false;
    $: if (userProfile?.displayName && !addedToHistory) {
        addedToHistory = true;
        addHistory({ category: "User", title: userProfile.displayName, url: $page.url.toString() });
    }

    let options: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => options = value);

    $: if (authorUrl) optionManager.setOption('home', { id: 'home', icon: House, iconProps: { weight: 'fill' }, href: authorUrl }, undefined, true);
    // $: if (authorUrl) optionManager.setOption('posts', { id: 'posts', name: "Posts", href: getUserUrl(authorUrl, user, "notes") }, eosed);
    $: if (authorUrl && $articles.length > 0) optionManager.setOption('articles', { id: 'articles', name: "Articles", badge: roundedItemCount($articles!), href: getUserUrl(authorUrl, user, "articles") }, eosed);
    $: if (authorUrl && $videos.length > 0) optionManager.setOption('videos', { id: 'videos', name: "Videos", badge: roundedItemCount($videos!), href: getUserUrl(authorUrl, user, "videos") }, eosed);
    $: if (authorUrl && $curations.length > 0) optionManager.setOption('curations', { id: 'curations', name: "Curations", badge: roundedItemCount($videos!), href: getUserUrl(authorUrl, user, "curations") }, eosed);
    $: if (authorUrl && $highlights.length > 0) optionManager.setOption('highlights', { id: 'highlights', name: "Highlights", badge: roundedItemCount($highlights!), href: getUserUrl(authorUrl, user, "highlights") }, eosed);
    $: if (authorUrl && $groupsList && $groupsList.items.length > 0) {
        optionManager.setOption('communities', { id: 'communities', name: "Communities", badge: roundedItemCount($groupsList!.items), href: getUserUrl(authorUrl, user, "communities") }, eosed);
    }

    $layout = {
        title: "Profile",
        sidebar: false,
    }

    $: {
        $layout.title = userProfile?.displayName ?? user.pubkey;
    }
</script>

<UserHeader {user} {userProfile} {fetching} {options} />

<slot
    {user}
    {userProfile}
    {fetching}
    {authorUrl}
    {highlights}
    {notes}
    {articles}
    {videos}
    {groupsList}
    {pinList}
    {tierList}
    {allTiers}
    {cashuMintList}
    {tiers}
/>