<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser";
	import { onMount, onDestroy } from "svelte";
	import { detailView, layoutMode, pageSidebar, resetLayout } from "$stores/layout";
	import { page } from '$app/stores';

    let startedUserView = false;
    let mounted = false;

    $layoutMode = "single-column-focused";
    $pageSidebar = {
        component: SettingsMenu,
        focused: true,
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