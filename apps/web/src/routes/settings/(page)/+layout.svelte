<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
	import { pageHeader, pageSidebar, resetLayout } from "$stores/layout";
	import { onDestroy } from 'svelte';

    $pageSidebar = {
        component: SettingsMenu,
        focused: false,
        props: {}
    }

    $pageHeader = {
        title: "Settings",
        left: {
            label: "Back",
            url: "/settings",
        },
        right: {
        }
    }

    onDestroy(() => {
        if ($pageSidebar) $pageSidebar.focused = true;
    })
</script>

<slot />