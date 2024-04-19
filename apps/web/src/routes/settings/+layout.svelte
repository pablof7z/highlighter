<script lang="ts">
	import LoadingScreen from "$components/LoadingScreen.svelte";
	import { pageSidebar } from "$stores/layout";
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser";
	import { onMount, onDestroy } from "svelte";

    let startedUserView = false;
    let mounted = false;

    onMount(() => {
        mounted = true;
    });

    $: console.log({currentUser: !!$currentUser})
    $: console.log({mounted})
    $: console.log({startedUserView})

    $: if (!!$currentUser && !startedUserView && mounted) {
        startUserView($currentUser);
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