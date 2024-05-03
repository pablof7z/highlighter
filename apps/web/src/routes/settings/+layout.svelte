<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser";
	import { onMount, onDestroy } from "svelte";
	import { detailView, layoutMode, resetLayout } from "$stores/layout";

    let startedUserView = false;
    let mounted = false;

    $layoutMode = "list-column";
    $detailView = {
        component: SettingsMenu,
        props: {}
    }

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

<slot />