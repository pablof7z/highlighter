<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser.js";
	import { onDestroy, onMount } from "svelte";
	import LoadingScreen from '$components/LoadingScreen.svelte';

    let startedUserView = false;
    let mounted = false;

    onMount(() => {
        mounted = true;
    });

    $: if (!!$user && !startedUserView && mounted) {
        startUserView($user);
        startedUserView = true;
    }

    onDestroy(() => {
        userSubscription?.unref();
    })
</script>

<LoadingScreen ready={!!startedUserView}>
    <slot />
</LoadingScreen>
