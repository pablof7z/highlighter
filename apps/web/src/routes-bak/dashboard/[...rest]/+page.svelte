<script lang="ts">
	import { startUserView } from '$stores/user-view';
	import { onMount } from 'svelte';
	import { pageHeader } from "$stores/layout";
	import NewPost from "$components/Creator/NewPost.svelte";
	import SupporterList from '$components/Supporters/SupporterList.svelte';
	import Box from '$components/PageElements/Box.svelte';
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { userTiers } from '$stores/session';
	import WelcomeGridItem from '$components/WelcomeGridItem.svelte';
	import DashboardStats from '$components/dashboard/DashboardStats.svelte';
	import currentUser from '$stores/currentUser';

    let mounted = false;

    if ($currentUser) startUserView($currentUser);

    onMount(() => {
        mounted = true;
    })

    $pageHeader = { title: "Dashboard" };
</script>

<LoadingScreen ready={mounted}>
    <div class="flex flex-col gap-10">
        <NewPost />

        {#if $userTiers.length === 0}
            <WelcomeGridItem />
        {/if}

        <DashboardStats />

        <!-- <ScheduleList /> -->

        <Box title="Supporters" innerClas="flex flex-col justify-stretch w-full">
            <SupporterList user={$currentUser} class="w-full" />
        </Box>

    </div>
</LoadingScreen>