<script lang="ts">
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import CreatorFeed from '$components/Feed/CreatorFeed.svelte';
	import Timeline from '$components/Events/Timeline.svelte';
    import SupporterList from "$components/Supporters/SupporterList.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import DashboardStats from '$components/dashboard/DashboardStats.svelte';
	import NewItemModal from "$modals/NewItemModal.svelte";
	import { getUserContent, getUserSupporters, startUserView } from '$stores/user-view';
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import type { Hexpubkey, NDKEvent } from '@nostr-dev-kit/ndk';
	import { SvelteComponent, onMount } from 'svelte';
	import { openModal } from "svelte-modals";
	import type { Readable } from 'svelte/motion';
	import UserProfile from '$components/User/UserProfile.svelte';
	import Tab from "$components/Tab.svelte";

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
            <Tab title="Posts" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Activity" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Stats" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Tiers" bind:value={activeTab} class="text-base sm:px-6" />
            <Tab title="Faaans" bind:value={activeTab} class="text-base sm:px-6" />
        </div>

        {#if activeTab === "Posts"}
            <CreatorFeed content={getUserContent()} />
        {:else if activeTab === "Activity"}
            ...
        {:else if activeTab === "Stats"}
            <DashboardStats />
        {:else if activeTab === "Tiers"}
        ...
        {:else if activeTab === "Faaans"}
            <SupporterList />
        {/if}
    </div>
</LoadingScreen>