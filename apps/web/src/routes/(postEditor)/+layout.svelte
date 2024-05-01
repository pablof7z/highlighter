<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import { user } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import LoadingScreen from '$components/LoadingScreen.svelte';
	import { layoutMaxWidth, layoutNavState, pageMainContentMaxWidth, resetLayout } from "$stores/layout";

    let startedUserView = false;
    let mounted = false;

    $layoutNavState = "collapsed";
    $layoutMaxWidth = "max-w-none";
    $pageMainContentMaxWidth = "max-w-6xl";

    onMount(() => {
        mounted = true;
    });

    $: if (!!$user && !startedUserView && mounted) {
        startedUserView = true;
        startUserView($user);
    }

    onDestroy(() => {
        userSubscription?.unref();
        resetLayout();
    })
</script>

<LoadingScreen ready={!!startedUserView}>
    <slot />
</LoadingScreen>
