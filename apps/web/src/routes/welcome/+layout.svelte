<script lang="ts">
	import { startUserView, userSubscription } from "$stores/user-view";
	import { user } from "@kind0/ui-common";
	import { onDestroy, onMount } from "svelte";
	import LoadingScreen from '$components/LoadingScreen.svelte';
    import { pageSidebar } from "$stores/layout";

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
        $pageSidebar = null;
    })
</script>

<LoadingScreen ready={!!startedUserView}>
    <slot />
</LoadingScreen>
