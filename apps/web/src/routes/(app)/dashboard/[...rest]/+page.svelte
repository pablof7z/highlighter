<script lang="ts">
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import CreatorFeed from '$components/Feed/CreatorFeed.svelte';
    import SupporterList from "$components/Supporters/SupporterList.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import DashboardStats from '$components/dashboard/DashboardStats.svelte';
	import { getUserContent, getUserSupporters, startUserView } from '$stores/user-view';
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import type { Hexpubkey } from '@nostr-dev-kit/ndk';
	import { onMount } from 'svelte';
	import type { Readable } from 'svelte/motion';
	import UserProfile from '$components/User/UserProfile.svelte';
	import Tab from "$components/Tab.svelte";
	import TierList from "$components/Creator/TierList.svelte";
	import { page } from "$app/stores";
	import CreatorActivity from "$components/Creator/CreatorActivity.svelte";

    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    const subscribers = $ndk.storeSubscribe(
        { kinds: [17001], "#p": [$user?.pubkey] }
    )
    let supporters: Readable<Record<Hexpubkey, string|undefined>> | undefined = undefined;

    let mounted = false;

    onMount(() => {
        startUserView($user);
        supporters = getUserSupporters();
        mounted = true;
    })

    let activeTab: string = 'Posts';

    $: switch ($page.params.rest) {
        case "activity": activeTab = "Activity"; break;
        case "stats": activeTab = "Stats"; break;
        case "tiers": activeTab = "Tiers"; break;
        case "faaans": activeTab = "Faaans"; break;
        default: activeTab = "Posts";
    }
</script>

<LoadingScreen ready={!!mounted && !!$user}>
    <div class="flex flex-col gap-10 mx-auto max-w-prose">
        <UserProfile user={$user} let:userProfile let:authorUrl let:fetching>
            <PageTitle title="Creator Dashboard">
                <div class="flex flex-row gap-2">
                    <!-- <button on:click={preview} class="button button-primary">Preview</button>
                    <button on:click={preview} class="button button-primary">Save Draft</button> -->
                    <a href={authorUrl} class="button">View Profile</a>
                </div>
            </PageTitle>


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

        <div role="tablist" class="tabs tabs-bordered w-full sm:w-fit">
            <Tab title="Posts" href="/dashboard/posts" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Activity" href="/dashboard/activity" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Stats" href="/dashboard/stats" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Tiers" href="/dashboard/tiers" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Faaans" href="/dashboard/faaans" bind:value={activeTab} class="text-base sm:px-6" />
        </div>

        {#if activeTab === "Posts"}
            <CreatorFeed content={getUserContent()} />
        {:else if activeTab === "Activity"}
            <CreatorActivity />
        {:else if activeTab === "Stats"}
            <DashboardStats />
        {:else if activeTab === "Tiers"}
            <TierList />
        {:else if activeTab === "Faaans"}
            <SupporterList />
        {/if}
    </div>
</LoadingScreen>