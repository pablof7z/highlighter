<script lang="ts">
	import { getUserSupporters, userSubscription, getUserSubscriptionTiersStore } from "$stores/user-view";
	import { Avatar, Name } from "@kind0/ui-common";
	import { NDKArticle, NDKKind, type NDKEventId, NDKUser } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { onDestroy, onMount } from "svelte";
    import { addReadReceipt } from "$utils/read-receipts";
	import { pageHeader } from '$stores/layout';
	import MainWrapper from '$components/Page/MainWrapper.svelte';
	import CreatorFooter from '$components/Creator/CreatorFooter.svelte';
	import type { UserProfileType } from '../../../app';
	import SubscribeButton from "$components/buttons/SubscribeButton.svelte";
	import Logo from "$icons/Logo.svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import CreatorProfileTabs from "./CreatorShell/CreatorProfileTabs.svelte";
	import CreatorShellSidebar from "./CreatorShell/CreatorShellSidebar.svelte";

    export let user: NDKUser;

    const userSupporters = getUserSupporters();

    let id: string;
    const defaultBanner = 'https://tonygiorgio.com/content/images/2023/03/cypherpunk-ostrach--copy--2.png';

    let scrollY = 0;
    let avatarWrapper = 'bg-transparent'; // Initial size of the avatar
    let avatarClass = 'w-28 h-28';

    function updateScroll() {
        scrollY = window.scrollY;
    }

    // Adjust avatar size based on scroll position
    $: if (scrollY > 100) { // Assuming 100px is the point where the banner is not visible

        avatarClass = 'w-14 h-14'; // Half the original size
        avatarWrapper = 'bg-black/90'; // Darken the avatar
    } else {
        avatarClass = 'w-28 h-28'; // Original size
        avatarWrapper = 'bg-transparent'; // Original color
    }

    onMount(() => {
        window.addEventListener('scroll', updateScroll);
    });

    onDestroy(() => {
        window.removeEventListener('scroll', updateScroll);
    });

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

    $: if (userProfile && !userProfile.banner) userProfile.banner = defaultBanner;

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

            <div class="py-4">
                <CreatorProfileTabs
                    bind:value={activeTab}
                    name={userProfile?.name}
                    pubkey={user.pubkey}
                    {user}
                    {authorUrl}
                />
            </div>
        </div>
        <div class="md:w-4/5 lg:w-3/5 border-x border-base-300">
            <UserProfile {user} bind:userProfile bind:fetching bind:authorUrl>
                <div class="relative w-full max-w-screen overflow-hidden max-sm:pb-[20vh] pb-[25%]">
                    <img src={userProfile?.banner??defaultBanner} class="absolute w-full h-full object-cover object-top lg:rounded" alt={userProfile?.name}>
                </div>
                <!-- Profile Header -->
                <div class="
                    flex
                    max-sm:flex-col max-sm:items-start max-sm:gap-4
                    overflow-clip
                    items-end justify-between p-3 sm:px-6 sm:py-4 -mt-16
                    gap-4
                    {avatarWrapper}
                    transition-all duration-300
                    w-full max-sm:w-screen
                    sticky top-0 z-50
                ">
                    <div class="flex items-end">
                        <Avatar user={user} {userProfile} {fetching} class="{avatarClass} transition-all duration-300 flex-none object-cover mask mask-squircle rounded-none" />

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
            </UserProfile>

            <div class="md:hidden">
                <div class="border-t border-base-300 my-4 py-4">
                    <CreatorProfileTabs
                        bind:value={activeTab}
                        {user}
                        name={userProfile?.name}
                        pubkey={user.pubkey}
                        {authorUrl}
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
