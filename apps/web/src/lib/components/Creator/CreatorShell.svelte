<script lang="ts">
	import { userSubscription, getUserSubscriptionTiersStore, getUserCurations, getUserHighlights, getGAUserContent, getUserContent, getUserSupporters, startUserView, userGroupList, userHighlights, userArticles, userWiki, userVideos } from "$stores/user-view";
	import { NDKArticle, NDKKind, type NDKEventId, NDKUser } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onDestroy, onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import { layout } from '$stores/layout';
	import type { NavigationOption, UserProfileType } from '../../../app';
	import currentUser from "$stores/currentUser";
	import CreatorFooter from "./CreatorShell/CreatorFooter.svelte";
	import { getUserUrl } from "$utils/url";
	import { addHistory } from "$stores/history";
	import { page } from "$app/stores";
	import CreatorHeader from "./CreatorHeader.svelte";

    export let user: NDKUser;
    
    onMount(() => {
        addReadReceipt(user);
        startUserView(user);
    })

    let addedToHistory = false;
    $: if (userProfile?.displayName && !addedToHistory) {
        addedToHistory = true;
        addHistory({ category: "User", title: userProfile.displayName, url: $page.url.toString() });
    }

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

    let authorUrl: string;
    let fetching: boolean;

    let hasCommunities = false;
    let hasCurations = false;
    let hasHighlights = false;
    let hasArticles = false;
    let hasVideos = false;
    let hasWiki = false;
    let hasPosts = false;
    let hasAccessToBackstage: boolean | undefined = undefined;

    let options: NavigationOption[] = [];

    $: if (!hasPosts && authorUrl) {
        hasPosts = true;
        options.push({ name: "Posts", href: getUserUrl(authorUrl, user, "notes") })
    }

    function roundedItemCount(items: any[], limit = 99): string {
        return items.length > limit ? `${limit}+` : items.length.toString();
    }

    $: if (!hasArticles) {
        hasArticles = !!($userArticles && $userArticles.length > 0)
        if (hasArticles) {
            options.push({ name: "Articles", badge: roundedItemCount($userArticles!), href: getUserUrl(authorUrl, user, "posts2") })
            options = options;
        }
    }

    $: if (!hasVideos) {
        hasVideos = !!($userVideos && $userVideos.length > 0);
        if (hasVideos) {
            options.push({ name: "Videos", badge: roundedItemCount($userVideos!), href: getUserUrl(authorUrl, user, "videos") })
            options = options;
        }
    }

    $: if (!hasHighlights) {
        hasHighlights = !!($userHighlights && $userHighlights.length > 0);
        if (hasHighlights) {
            options.push({ name: "Highlights", badge: roundedItemCount($userHighlights!), href: getUserUrl(authorUrl, user, "highlights") })
            options = options;
        }
    }

    $: if (!hasCommunities) {
        hasCommunities = !!($userGroupList && $userGroupList.items.length > 0);
        if (hasCommunities) {
            options.push({ name: "Communities", badge: roundedItemCount($userGroupList!.items), href: getUserUrl(authorUrl, user, "communities") })
            options = options;
        }
    }

    $: if (!hasWiki) {
        hasWiki = !!($userWiki && $userWiki.length > 0);
        if (hasWiki) {
            options.push({ name: "Wiki", badge: roundedItemCount($userWiki!), href: getUserUrl(authorUrl, user, "wiki") })
            options = options;
        }
    }

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
        footer: {
            component: CreatorFooter,
            props: {
                user
            }
        }
    }

    $: $layout.title = userProfile?.displayName ?? user.pubkey;
    $: $layout.iconUrl = userProfile?.image;
    $: $layout.navigation = options;
</script>

<UserProfile {user} bind:userProfile bind:fetching bind:authorUrl />

<slot />
