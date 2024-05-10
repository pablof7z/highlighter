<script lang="ts">
	import { userSubscription, getUserSubscriptionTiersStore, getUserCurations, getUserHighlights, getGAUserContent, getUserContent } from "$stores/user-view";
	import { NDKArticle, NDKKind, type NDKEventId, NDKUser } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onDestroy, onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import { pageHeader, pageHeaderComponent, pageNavigationOptions } from '$stores/layout';
	import type { UserProfileType } from '../../../app';
	import CreatorHeader from "./CreatorHeader.svelte";
	import { Article, BookmarkSimple, House, Notepad, User } from "phosphor-svelte";
	import { Avatar, HighlightIcon } from "@kind0/ui-common";

    export let user: NDKUser;

    const userTiers = getUserSubscriptionTiersStore();

    const highlights = getUserHighlights();
    const gaContent = getGAUserContent();
    const userContent = getUserContent();
    const curations = getUserCurations();
    
    onMount(() => {
        addReadReceipt(user);
    })

    let articles: Readable<Map<NDKEventId, NDKArticle>>;

    $: if (!articles && userSubscription && $userSubscription) {
        articles = derived(userSubscription, $userSubscription => {
            const articles = new Map<NDKEventId, NDKArticle>();

            for (const event of $userSubscription) {
                if (
                    event.pubkey !== user.pubkey ||
                    event.kind !== NDKKind.Article
                ) continue;

                const id = event.encode();
                if (!articles.has(id)) articles.set(id, NDKArticle.from(event));
            }

            return articles;
        });
    }

    let userProfile: UserProfileType | undefined = undefined;

    $: $pageHeader = {}

    let authorUrl: string;
    let fetching: boolean;

    let hasCurations = false;
    let hasHighlights = false;
    let hasPublications = false;

    $: {
        $pageNavigationOptions = [];

        if (!hasPublications && ($gaContent.length > 0 || $userContent.length > 0)) { hasPublications = true; }
        if (!hasCurations && $curations.length > 0) { hasCurations = true; }
        if (!hasHighlights && $highlights.length > 0) { hasHighlights = true; }

        $pageNavigationOptions.push({ name: "Home", href: `${authorUrl}`, icon: User });

        $pageNavigationOptions.push({ name: "Notes", href: `${authorUrl}/notes`, icon: Notepad },)
        if (hasCurations)
            $pageNavigationOptions.push({ name: "Curations", href: `${authorUrl}/curations`, icon: BookmarkSimple },)

        if (hasPublications)
            $pageNavigationOptions.push({ name: "Publications", href: `${authorUrl}/posts`, icon: Article },)

        if (hasHighlights)
        $pageNavigationOptions.push({ name: "Highlights", href: `${authorUrl}/highlights`, icon: HighlightIcon },)
    }

    $: {
        $pageHeaderComponent = {
            component: CreatorHeader,
            props: { user, userProfile, authorUrl, fetching, tiers: userTiers },
            containerClass: ''
        }
    }

    onDestroy(() => {
        $pageHeaderComponent = null;
    })
</script>

<UserProfile {user} bind:userProfile bind:fetching bind:authorUrl />

<slot />

<div class="hidden bg-black/90 w-14 h-14 w-28 h-28"></div>