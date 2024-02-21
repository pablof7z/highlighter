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

    let activeTab: string = "Publications";

    $: $pageHeader = {}
</script>

<svelte:head>
    <title>{userProfile?.name ?? id} on Highlighter</title>
    <meta name="description" content="Creator profile" />
    <meta property="og:title" content={user.npub} />
    <meta property="og:description" content="Creator profile" />
    <meta property="og:image" content={userProfile?.image || defaultBanner} />
</svelte:head>

<MainWrapper class="sm:px-6" marginClass="max-w-3xl mx-auto" mobilePadded={false}>
    <UserProfile {user} bind:userProfile let:fetching let:authorUrl>
        <div class="relative w-full max-w-screen overflow-hidden max-sm:pb-[20vh] pb-[25%]">
            <img src={userProfile?.banner??defaultBanner} class="absolute w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
        </div>
        <!-- Profile Header -->
        <div class="
            flex
            max-sm:flex-col max-sm:items-start max-sm:gap-4
            overflow-clip
            items-end justify-between p-3 sm:p-6 relative -mt-16
            gap-4
            w-full max-sm:w-screen
        ">
            <div class="flex items-end">
                <Avatar user={user} {userProfile} {fetching} class="w-28 h-28 flex-none object-cover mask mask-squircle rounded-none" />

                <div class="ml-4 overflow-clip">
                    <div class="name text-xl font-semibold text-base-100-content">
                        <Name {userProfile} {fetching} />
                    </div>
                    <p class="text-sm truncate max-w-md text-neutral-500 w-full basis-0 shrink">
                        {#if fetching && !userProfile?.about}
                            <div class="skeleton h-15 w-48">&nbsp;</div>
                        {:else if userProfile?.about}
                            {userProfile?.about}
                        {:else}
                            &nbsp;
                        {/if}
                    </p>
                </div>
            </div>

            {#if $userTiers}
                <SubscribeButton {user} {userProfile} tiers={userTiers} />
            {/if}
        </div>

        <div class="border-t border-b border-neutral-800 py-3 mb-6">
            <CreatorProfileTabs
                bind:value={activeTab}
                name={userProfile?.name}
                pubkey={user.pubkey}
                {authorUrl}
            />
        </div>
    </UserProfile>


    {#if activeTab === "Backstage"}
        <div class="flex flex-row gap-10">
            <CreatorFeed onlyBackstageContent={true} />
        </div>
    {:else if activeTab === "Publications"}
        <div class="flex flex-row gap-10">
            <CreatorFeed />
        </div>
    {:else if activeTab === "Curations"}
        <Curations
            filter={{"authors": [user.pubkey]}}
        />
    {:else if activeTab === "Highlights"}
        <Highlights
            filter={{"authors": [user.pubkey]}}
        />
    {:else if activeTab === "Supporters"}
        <SupporterList
            {user}
        />
    {:else if activeTab === "Supported Creators"}
        <CreatorsList
            creators={getUserSupporters()}
        />
    {/if}
</MainWrapper>

<CreatorFooter {user} tiers={userTiers} userSupporters={getUserSupporters()} />

<style lang="postcss">
    .name {
        @apply max-w-sm truncate;
    }
</style>