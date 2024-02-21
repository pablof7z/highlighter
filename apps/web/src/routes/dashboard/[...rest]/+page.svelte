<script lang="ts">
	import { getUserSubscriptionTiersStore, startUserView } from '$stores/user-view';
	import { user } from "@kind0/ui-common";
	import { onMount } from 'svelte';
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";
	import NewPost from "$components/Creator/NewPost.svelte";
	import SupporterList from '$components/Supporters/SupporterList.svelte';
	import Box from '$components/PageElements/Box.svelte';
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { userTiers } from '$stores/session';
	import WelcomeGridItem from '$components/WelcomeGridItem.svelte';
	import DashboardStats from '$components/dashboard/DashboardStats.svelte';

    let mounted = false;

    if ($user) startUserView($user);

    onMount(() => {
        mounted = true;
    })

    $pageHeader = { title: "Dashboard" };
</script>

<LoadingScreen ready={mounted}>
    <MainWrapper marginClass="max-w-3xl mx-auto">
        <div class="flex flex-col gap-10">
            <NewPost />

            {#if $userTiers.length === 0}
                <WelcomeGridItem />
            {/if}

            <DashboardStats />

            <!-- <ScheduleList /> -->

            <Box title="Supporters" innerClas="flex flex-col justify-stretch w-full">
                <SupporterList user={$user} class="w-full" />
            </Box>

        </div>
    </MainWrapper>
</LoadingScreen>