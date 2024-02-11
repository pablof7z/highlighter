<script lang="ts">
    import LoadingScreen from "$components/LoadingScreen.svelte";
	import { getUserContent, getUserSupporters, startUserView, getGAUserContent } from '$stores/user-view';
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import { type Hexpubkey } from '@nostr-dev-kit/ndk';
	import { onDestroy, onMount } from 'svelte';
	import type { Readable } from 'svelte/motion';
	import UserProfile from '$components/User/UserProfile.svelte';
	import CreatorActivity from "$components/Creator/CreatorActivity.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import { pageHeader } from "$stores/layout";

    let mounted = false;

    onMount(() => {
        startUserView($user);
        mounted = true;
    })

    $pageHeader = { title: "Notifications" }
</script>

<LoadingScreen ready={!!mounted && !!$user}>
    <MainWrapper class="flex flex-col gap-10">
        <CreatorActivity />
    </MainWrapper>
</LoadingScreen>