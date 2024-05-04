<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
	import { pageSidebar, resetLayout } from "$stores/layout";
	import { onDestroy } from 'svelte';

    $pageSidebar = {
        component: SettingsMenu,
        focused: false,
        props: {}
    }

    onDestroy(() => {
        if ($pageSidebar) $pageSidebar.focused = true;
    })
</script>

<slot />