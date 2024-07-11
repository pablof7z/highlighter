<script lang="ts">
	import { getUserSupporters } from "$stores/user-view";
	import { NDKKind, NDKUser, NDKList, NDKHighlight, NDKEvent, NDKArticle, NDKVideo, NDKWiki, NDKUserProfile, NDKSubscriptionTier, NDKSimpleGroup, NDKRelaySet, NDKTag, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
	import { derived, get, Readable, writable } from "svelte/store";
	import { setContext } from "svelte";
	import { layout } from '$stores/layout';
	import type { NavigationOption } from '../../../app';
	import currentUser from "$stores/currentUser";
	import { getUserUrl } from "$utils/url";
	import { addHistory } from "$stores/history";
	import { page } from "$app/stores";
    import {Navigation} from "$utils/navigation";
	import { ndk } from "$stores/ndk";
    import UserHeader from "./Header.svelte";
	import { House } from "phosphor-svelte";
	import { roundedItemCount } from "$utils/numbers";
	import Footer from "./Footer.svelte";
    import { deriveStore, deriveListStore } from "$utils/events/derive.js";
	import Tier from "$components/Tier.svelte";
	import { filterArticle } from "$utils/article-filter";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | undefined | null;
    export let authorUrl: string;
    export let fetching: boolean;

    let eosed = false;
    const  onEose = () => eosed = true;

    $ndk.outboxTracker!.track(user);

    const events = $ndk.storeSubscribe([
        { kinds: [ NDKKind.Text, NDKKind.GroupNote, NDKKind.GroupReply ], authors: [user.pubkey], limit: 50 },
        { kinds: [ NDKKind.Article ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.Wiki ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.HorizontalVideo, NDKKind.VerticalVideo ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.Media ], "#m": [ "video/mp4"], authors: [user.pubkey], limit: 10 },
        { kinds: [ NDKKind.Highlight ], authors: [user.pubkey], limit: 100 },
        { kinds: [ NDKKind.TierList, NDKKind.SimpleGroupList, NDKKind.PinList ], authors: [user.pubkey] },
        { kinds: [ NDKKind.SubscriptionTier ], authors: [user.pubkey], limit: 100 },
    ], { subId: 'user-events', groupable: false, onEose });

    const userHighlights = deriveStore<NDKHighlight>(events, NDKHighlight)
    const userNotes = deriveStore<NDKEvent>(events, undefined, [NDKKind.Text, NDKKind.Repost, NDKKind.GenericRepost, NDKKind.GroupNote, NDKKind.GroupReply]);
    const userArticlesAll = deriveStore<NDKArticle>(events, NDKArticle);
    const userVideos = deriveStore<NDKVideo>(events, NDKVideo);
    const userWiki = deriveStore<NDKWiki>(events, NDKWiki);
    const userGroupsList = deriveListStore<NDKList>(events, NDKList, [NDKKind.SimpleGroupList]);
    const userPinList = deriveListStore<NDKList>(events, NDKList, [NDKKind.PinList]);
    const userTierList = deriveListStore<NDKList>(events, NDKList, [NDKKind.TierList]);
    const userAllTiers = deriveStore<NDKSubscriptionTier>(events, NDKSubscriptionTier);

    const userArticles = derived(userArticlesAll, $userArticlesAll => {
        return $userArticlesAll.filter(filterArticle);
    });

    const userGroups = writable<Record<string, NDKSimpleGroup>>({});
    const userGroupsMetadata = writable<Record<string, NDKSimpleGroupMetadata>>({});

    // load groups
    let loadedGroups = new Set<string>();
    $: if ($userGroupsList && $userGroupsList.items) {
        for (const group of $userGroupsList.items) {
            const groupId = group[1];
            if (!loadedGroups.has(groupId)) {
                loadedGroups.add(groupId);
                loadGroup(group);
            }
        }
    }

    async function loadGroup(tag: NDKTag) {
        const [ _, groupId, relay ] = tag;
        const relaySet = NDKRelaySet.fromRelayUrls([relay], $ndk);
        const group = new NDKSimpleGroup($ndk, relaySet, groupId);
        group.getMemberListEvent();
        group.getMetadata().then((metadata) => {
            userGroupsMetadata.update(groups => {
                groups[groupId] = metadata;
                return groups;
            });
        });

        userGroups.update(groups => {
            groups[groupId] = group;
            return groups;
        });
    }

    const userTiers = derived([userTierList, userAllTiers], ([$userTierList, $userAllTiers]) => {
        if (!$userTierList) return [];

        const eTags = $userTierList.getMatchingTags("e").map(t => t[1]);
        return $userAllTiers
            .filter(tier => eTags.includes(tier.id))
            // .filter(tier => tier.tagValue("h"))
    });

    setContext('user', user);
    setContext('userNotes', userNotes);
    setContext('userHighlights', userHighlights);
    setContext('userArticles', userArticles);
    setContext('userVideos', userVideos);
    setContext('userWiki', userWiki);
    setContext('userGroupsList', userGroupsList);
    setContext('userPinList', userPinList);
    setContext('userTierList', userTierList);
    setContext('userTiers', userTiers);
    setContext('userGroups', userGroups);
    setContext('userGroupsMetadata', userGroupsMetadata);

    let addedToHistory = false;
    $: if (userProfile?.displayName && !addedToHistory) {
        addedToHistory = true;
        addHistory({ category: "User", title: userProfile.displayName, url: $page.url.toString() });
    }

    let options: NavigationOption[] = [];
    const optionManager = new Navigation();
    optionManager.options.subscribe(value => options = value);

    $: if (authorUrl) optionManager.setOption('home', { id: 'home', icon: House, iconProps: { weight: 'fill' }, href: authorUrl }, undefined, true);
    $: if (authorUrl) optionManager.setOption('posts', { id: 'posts', name: "Posts", href: getUserUrl(authorUrl, user, "notes") }, eosed);
    $: if (authorUrl && $userArticles.length > 0) optionManager.setOption('articles', { id: 'articles', name: "Articles", badge: roundedItemCount($userArticles!), href: getUserUrl(authorUrl, user, "articles") }, eosed);
    $: if (authorUrl && $userVideos.length > 0) optionManager.setOption('videos', { id: 'videos', name: "Videos", badge: roundedItemCount($userVideos!), href: getUserUrl(authorUrl, user, "videos") }, eosed);
    $: if (authorUrl && $userHighlights.length > 0) optionManager.setOption('highlights', { id: 'highlights', name: "Highlights", badge: roundedItemCount($userHighlights!), href: getUserUrl(authorUrl, user, "highlights") }, eosed);
    $: if (authorUrl && $userGroupsList && $userGroupsList.items.length > 0) {
        optionManager.setOption('communities', { id: 'communities', name: "Communities", badge: roundedItemCount($userGroupsList!.items), href: getUserUrl(authorUrl, user, "communities") }, eosed);
    }
    $: if (authorUrl && $userWiki.length > 0) optionManager.setOption('wiki', { id: 'wiki', name: "Wiki", badge: roundedItemCount($userWiki!), href: getUserUrl(authorUrl, user, "wiki") }, eosed);

    $layout = {
        title: "Profile",
        sidebar: false,
    }

    $: {
        $layout.title = userProfile?.displayName ?? user.pubkey;
        console.log('setting title', $layout.title)
    }
    $: $layout.iconUrl = userProfile?.image;
    $: $layout.footer = {
        component: Footer,
        props: { user, userProfile, fetching, authorUrl }
    }
</script>

<UserHeader {user} {userProfile} {fetching} {options} />

<slot />