<script lang="ts">
    import LoadingScreen from "$components/LoadingScreen.svelte";
	import CreatorFeed from '$components/Feed/CreatorFeed.svelte';
	import { getUserContent, getUserSupporters, startUserView, getGAUserContent } from '$stores/user-view';
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import { type Hexpubkey } from '@nostr-dev-kit/ndk';
	import { onDestroy, onMount } from 'svelte';
	import type { Readable } from 'svelte/motion';
	import UserProfile from '$components/User/UserProfile.svelte';
	import Tab from "$components/Tab.svelte";
	import TierList from "$components/Creator/TierList.svelte";
	import { page } from "$app/stores";
	import CreatorActivity from "$components/Creator/CreatorActivity.svelte";
	import DraftList from "$components/Creator/DraftList.svelte";
	import { drafts } from "$stores/drafts";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";
	import DashboardStats from "$components/dashboard/DashboardStats.svelte";

    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    const subscribers = $ndk.storeSubscribe(
        { kinds: [17001], "#p": [$user?.pubkey] }
    )
    let supporters: Readable<Record<Hexpubkey, string|undefined>> | undefined = undefined;

    let mounted = false;

    onDestroy(() => {
        subscribers?.unsubscribe();
    })

    onMount(() => {
        startUserView($user);
        supporters = getUserSupporters();
        mounted = true;
    })

    let activeTab: string = 'Activity';

    $: switch ($page.params.rest) {
        case "activity": activeTab = "Activity"; break;
        case "stats": activeTab = "Stats"; break;
        case "tiers": activeTab = "Tiers"; break;
        case "faaans": activeTab = "Faaans"; break;
        case "drafts": activeTab = "Drafts"; break;
        default: activeTab = "Posts";
    }

    $pageHeader = { title: "Notifications" }
</script>

<LoadingScreen ready={!!mounted && !!$user}>
    <MainWrapper class="flex flex-col gap-10">
        <UserProfile user={$user} let:userProfile let:authorUrl let:fetching>
            <a href={authorUrl} class="flex flex-row items-center gap-4 text-left">
                <Avatar user={$user} {userProfile} {fetching} class="w-32 h-32" />

                <div class="flex flex-col gap-2">
                    <Name user={$user} {userProfile} {fetching} class="text-xl font-semibold text-white" />
                    {#if supportingPubkeys && $supporters}
                        <div class="text-white text-opacity-60 text-sm font-normal leading-6">
                            {$subscribers.length}
                            subscribers  ·  {Object.entries($supporters).length??0} paying supporters
                        </div>
                    {/if}
                </div>
            </a>
        </UserProfile>

        <div class="flex flex-row gap-10 mx-auto">
            <div class="flex flex-col gap-10 mx-auto max-w-prose">
                <div role="tablist" class="tabs tabs-bordered w-full sm:w-fit">
                    <Tab title="Activity" href="/notifications/activity" bind:value={activeTab} class="text-base sm:px-6" />
                    <Tab title="Stats" href="/notifications/stats" bind:value={activeTab} class="text-base sm:px-6" />
                    <Tab title="Tiers" href="/notifications/tiers" bind:value={activeTab} class="text-base sm:px-6" />

                    {#if $drafts.length > 0}
                        <Tab title="Drafts" href="/notifications/drafts" bind:value={activeTab} class="text-base sm:px-6" />
                    {/if}
                </div>

                <CreatorActivity />

                {#if activeTab === "Activity"}
                    <CreatorActivity />
                {:else if activeTab === "Stats"}
                    <DashboardStats />
                {/if}
            </div>
<!--
            <div class:hidden={allOnboardingDone}>
                <OnboardingChecklist bind:allDone={allOnboardingDone} />
            </div> -->
        </div>
    </MainWrapper>
</LoadingScreen>