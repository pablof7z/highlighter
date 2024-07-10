<script lang="ts">
	import { getUserSupporters } from "$stores/user-view";
	import { NDKKind, NDKUser, NDKList, NDKHighlight, NDKEvent, NDKArticle, NDKVideo, NDKWiki, NDKUserProfile, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { derived, get, Readable } from "svelte/store";
	import { setContext } from "svelte";
	import { layout } from '$stores/layout';
	import type { NavigationOption } from '../../../app';
	import currentUser from "$stores/currentUser";
	import { getUserUrl } from "$utils/url";
	import { addHistory } from "$stores/history";
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk";
    import UserHeader from "./Header.svelte";
	import { chronologically } from "$utils/event";
	import { House } from "phosphor-svelte";
	import { roundedItemCount } from "$utils/numbers";
	import Footer from "./Footer.svelte";

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

    type NDKEventWithFrom<T> = { from?: (event: NDKEvent) => T, kind?: NDKKind, kinds?: NDKKind[]};

    function deriveStore<T>(
        store: Readable<NDKEvent[]>,
        klass?: NDKEventWithFrom<T>,
        kinds?: NDKKind[]
    ): Readable<T[]> {
        kinds ??= klass?.kinds;
        if (!kinds && klass?.kind) kinds = [klass.kind];
        if (!kinds) throw new Error("No kinds provided and none could be inferred from the class");

        return derived(store, $events => {
            const filtered = $events.filter(event => kinds!.includes(event.kind!));

            if (klass?.from)
                return filtered.map(e => klass.from!(e));
            else 
                return filtered as unknown as T[];
        });
    }

    function deriveListStore<T>(
        store: Readable<NDKEvent[]>,
        klass?: NDKEventWithFrom<T>,
        kinds?: NDKKind[]
    ): Readable<T | undefined> {
        kinds ??= klass?.kinds;
        if (!kinds && klass?.kind) kinds = [klass.kind];
        if (!kinds) throw new Error("No kinds provided and none could be inferred from the class");

        return derived(store, $events => {
            const lists = $events.filter(event => kinds!.includes(event.kind!));
            const event = lists.sort(chronologically)[0];
            return event ? klass?.from!(event) : undefined;
        })
    }

    const userHighlights = deriveStore<NDKHighlight>(events, NDKHighlight)
    const userNotes = deriveStore<NDKEvent>(events, undefined, [NDKKind.Text, NDKKind.Repost, NDKKind.GenericRepost, NDKKind.GroupNote, NDKKind.GroupReply]);
    const userArticles = deriveStore<NDKArticle>(events, NDKArticle);
    const userVideos = deriveStore<NDKVideo>(events, NDKVideo);
    const userWiki = deriveStore<NDKWiki>(events, NDKWiki);
    const userGroupsList = deriveListStore<NDKList>(events, NDKList, [NDKKind.SimpleGroupList]);
    const userPinList = deriveListStore<NDKList>(events, NDKList, [NDKKind.PinList]);
    const userTierList = deriveListStore<NDKList>(events, NDKList, [NDKKind.TierList]);
    const userAllTiers = deriveStore<NDKSubscriptionTier>(events, NDKSubscriptionTier);

    const userTiers = derived([userTierList, userAllTiers], ([$userTierList, $userAllTiers]) => {
        if (!$userTierList) return [];

        const eTags = $userTierList.getMatchingTags("e").map(t => t[1]);
        return $userAllTiers.filter(tier => eTags.includes(tier.id));
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

    let addedToHistory = false;
    $: if (userProfile?.displayName && !addedToHistory) {
        addedToHistory = true;
        addHistory({ category: "User", title: userProfile.displayName, url: $page.url.toString() });
    }

    let hasAccessToBackstage: boolean | undefined = undefined;

    const existingOptions = new Set();
    let options: NavigationOption[] = []

    function setOption(name: string, option: NavigationOption, eosed?: boolean, prepend = false) {
        const alreadyExists = existingOptions.has(name);
        if (!eosed && alreadyExists) return;
        if (!eosed) delete option.badge;

        let insertIndex = -1;

        // If the option already exists, find its index and remove it
        if (alreadyExists) {
            insertIndex = options.findIndex(o => o.id === name);
            options = options.filter(o => o.id !== name);
        }

        // Insert the option at the correct position
        if (insertIndex !== -1 && !prepend) {
            options = [...options.slice(0, insertIndex), option, ...options.slice(insertIndex)];
        } else {
            if (prepend) {
                options = [option, ...options];
            } else {
                options = [...options, option];
            }
        }

        existingOptions.add(name);
    }
    
    $: if (authorUrl) setOption('home', { id: 'home', icon: House, iconProps: { weight: 'fill' }, href: authorUrl }, undefined, true);
    $: if (authorUrl) setOption('posts', { id: 'posts', name: "Posts", href: getUserUrl(authorUrl, user, "notes") }, eosed);
    $: if (authorUrl && $userArticles.length > 0) setOption('articles', { id: 'articles', name: "Articles", badge: roundedItemCount($userArticles!), href: getUserUrl(authorUrl, user, "articles") }, eosed);
    $: if (authorUrl && $userVideos.length > 0) setOption('videos', { id: 'videos', name: "Videos", badge: roundedItemCount($userVideos!), href: getUserUrl(authorUrl, user, "videos") }, eosed);
    $: if (authorUrl && $userHighlights.length > 0) setOption('highlights', { id: 'highlights', name: "Highlights", badge: roundedItemCount($userHighlights!), href: getUserUrl(authorUrl, user, "highlights") }, eosed);
    $: if (authorUrl && $userGroupsList && $userGroupsList.items.length > 0) {
        setOption('communities', { id: 'communities', name: "Communities", badge: roundedItemCount($userGroupsList!.items), href: getUserUrl(authorUrl, user, "communities") }, eosed);
    }
    $: if (authorUrl && $userWiki.length > 0) setOption('wiki', { id: 'wiki', name: "Wiki", badge: roundedItemCount($userWiki!), href: getUserUrl(authorUrl, user, "wiki") }, eosed);

    const supporters = getUserSupporters();

    $: if (hasAccessToBackstage === undefined && user && $currentUser) {
        if (user.pubkey === $currentUser.pubkey) {
            hasAccessToBackstage = true;
        } else if ($supporters) {
            if ($supporters[user.pubkey]) hasAccessToBackstage = true;
        }
    }

    $layout = {
        title: "Profile",
        sidebar: false,
    }

    $: $layout.title = userProfile?.displayName ?? user.pubkey;
    $: $layout.iconUrl = userProfile?.image;
    $: $layout.footer = {
        component: Footer,
        props: { user, userProfile, fetching, authorUrl }
    }
</script>

<UserHeader {user} {userProfile} {fetching} bind:options />

<slot />