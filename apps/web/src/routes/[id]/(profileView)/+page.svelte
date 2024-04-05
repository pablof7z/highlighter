<script lang="ts">
	import { page } from "$app/stores";
	import CreatorFeed from "$components/Feed/CreatorFeed.svelte";
	import { getUserSupporters, userSubscription, getUserSubscriptionTiersStore } from "$stores/user-view";
	import { Avatar, Name, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKEventId } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import CreatorProfileTabs from './CreatorProfileTabs.svelte';
	import Curations from '$components/Curations.svelte';
	import Highlights from '$components/Highlights.svelte';
	import { pageHeader } from '$stores/layout';
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import CreatorFooter from '$components/Creator/CreatorFooter.svelte';
	import type { UserProfileType } from '../../app';
	import CreatorsList from "$components/CreatorsList.svelte";
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import SupporterList from "$components/Supporters/SupporterList.svelte";
	import ForumFeed from "$components/Feed/ForumFeed.svelte";
	import Logo from "$icons/Logo.svelte";

    let id: string;
    let { user } = $page.data;
    const defaultBanner = 'https://tonygiorgio.com/content/images/2023/03/cypherpunk-ostrach--copy--2.png';

    const userTiers = getUserSubscriptionTiersStore();

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        user.ndk = $ndk;
    }

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

    let userProfile: UserProfileType;

    $: if (userProfile && !userProfile.banner) userProfile.banner = defaultBanner;

    $: $pageHeader = {}
</script>

<svelte:head>
    <title>{userProfile?.name ?? id} on Highlighter</title>
    <meta name="description" content="Creator profile" />
    <meta property="og:title" content={user.npub} />
    <meta property="og:description" content="Creator profile" />
    <meta property="og:image" content={userProfile?.image || defaultBanner} />
</svelte:head>

<CreatorFeed />