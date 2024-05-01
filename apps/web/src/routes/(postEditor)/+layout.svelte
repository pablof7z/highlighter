<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import { onDestroy, onMount } from "svelte";
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { layoutMode, resetLayout } from "$stores/layout";
    import currentUser from "$stores/currentUser";

    let startedUserView = false;
    let mounted = false;

    $layoutMode = "single-column-focused";

    onMount(() => {
        mounted = true;
    });

    $: if (mounted && $currentUser && !startedUserView) {
        startUserView($currentUser);
        startedUserView = true;
    }

    onDestroy(() => {
        userSubscription?.unref();
        resetLayout();
    })
</script>

<LoadingScreen ready={!!startedUserView}>
    <slot />
</LoadingScreen>
