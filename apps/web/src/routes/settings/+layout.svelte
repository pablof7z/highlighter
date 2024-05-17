<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
	import { startUserView, userSubscription } from "$stores/user-view";
	import currentUser from "$stores/currentUser";
	import { onMount, onDestroy } from "svelte";
	import { layoutMode, pageSidebar, resetLayout } from "$stores/layout";
	import { appMobileView } from '$stores/app';

    let startedUserView = false;
    let mounted = false;

    $layoutMode = "single-column-focused";
    $: if (!$appMobileView) {
        $pageSidebar = {
            component: SettingsMenu,
            focused: true,
            props: {}
        }
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