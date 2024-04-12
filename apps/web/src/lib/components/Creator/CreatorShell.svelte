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

    let userProfile: UserProfileType;

    let activeTab: string = "Publications";

    $: $pageHeader = {}

    let authorUrl: string;
    let fetching: boolean;
</script>

<MainWrapper
    marginClass="max-w-6xl mx-auto"
    paddingClass="md:px-4"
    mobilePadded={false}
    headerMarginClass="
        md:max-w-3xl md:mx-auto md:px-4
    "
>
    <div class="flex flex-row w-full relative h-full grow">
        <div class="md:w-1/5 h-full hidden md:block sticky top-0 grow pt-10">
            <Logo class="w-40" />

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
        <div class="md:w-4/5 lg:w-3/5 border-x border-base-300">
            <UserProfile {user} bind:userProfile bind:fetching bind:authorUrl>
                <div class="relative w-full max-w-screen overflow-hidden max-sm:pb-[20vh] pb-[25%] max-sm:hidden">
                    {#if userProfile?.banner}
                        <img src={userProfile?.banner} class="absolute w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
                    {:else}
                        <div class="absolute w-full h-full object-cover object-top lg:rounded bg-gradient-to-b from-base-300 to-transparent via-bg-base-300" />
                    {/if}
                </div>
                <!-- Profile Header -->
                <CreatorHeader {user} {userProfile} {fetching} tiers={userTiers} />
            </UserProfile>

            <div class="md:hidden">
                <div class="border-t border-base-300 mt-4 mb-2">
                    <CreatorProfileTabs
                        bind:value={activeTab}
                        {user}
                        {authorUrl}
                        skipSubscribeButton={true}
                    />
                </div>
            </div>

            <slot />
        </div>
        <div class="lg:w-1/5 max-lg:hidden grow pt-10">
            <CreatorShellSidebar {user} {userSupporters} />
        </div>
    </div>
</MainWrapper>

<!-- <CreatorFooter {user} tiers={userTiers} userSupporters={userSupporters} /> -->

<div class="hidden bg-black/90 w-14 h-14 w-28 h-28"></div>