<script lang="ts">
	import { getUserSupporters, userSubscription, getUserSubscriptionTiersStore } from "$stores/user-view";
	import { NDKArticle, NDKKind, type NDKEventId, NDKUser } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import { pageHeader } from '$stores/layout';
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import type { UserProfileType } from '../../../app';
	import Logo from "$icons/Logo.svelte";
	import CreatorProfileTabs from "./CreatorShell/CreatorProfileTabs.svelte";
	import CreatorShellSidebar from "./CreatorShell/CreatorShellSidebar.svelte";
	import CreatorHeader from "./CreatorHeader.svelte";
	import LogoSmall from "$icons/LogoSmall.svelte";
	import ThreeColumn from "$components/Layouts/ThreeColumn.svelte";

    export let user: NDKUser;

    const userSupporters = getUserSupporters();

    const userTiers = getUserSubscriptionTiersStore();

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

    let activeTab: string = "Publications";

    $: $pageHeader = {}

    let authorUrl: string;
    let fetching: boolean;
</script>

<UserProfile {user} bind:userProfile bind:fetching bind:authorUrl />

<ThreeColumn>
    <div slot="left">
        <div class="hidden xl:block">
            <Logo class="w-40" />
        </div>
        <!-- <div class="xl:hidden">
            <LogoSmall class="w-10" />
        </div> -->

        <div class="my-4"></div>

        <div class="lg:py-4 pr-4">
            <CreatorProfileTabs
                bind:value={activeTab}
                {userProfile}
                {user}
                {authorUrl}
            />
        </div>
    </div>

    <div class="relative w-full max-w-screen overflow-hidden max-sm:pb-[20vh] pb-[25%] max-sm:hidden">
        {#if userProfile?.banner}
            <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
        {:else}
            <div class="absolute w-full h-full object-cover object-top lg:rounded bg-gradient-to-b from-base-300 to-transparent via-bg-base-300" />
        {/if}
    </div>
    <!-- Profile Header -->
    <CreatorHeader {user} {userProfile} {fetching} tiers={userTiers} />

    <div class="md:hidden sticky top-14 z-50 bg-black/90">
        <div class="border-t border-base-300">
            <CreatorProfileTabs
                bind:value={activeTab}
                {user}
                {authorUrl}
                skipSubscribeButton={true}
            />
        </div>
    </div>

    <slot />

    <div slot="right" class="xl:w-1/5 hidden xl:block grow pt-10">
        <CreatorShellSidebar {user} {userSupporters} />
    </div>
</ThreeColumn>

<!-- <CreatorFooter {user} tiers={userTiers} userSupporters={userSupporters} /> -->

<div class="hidden bg-black/90 w-14 h-14 w-28 h-28"></div>