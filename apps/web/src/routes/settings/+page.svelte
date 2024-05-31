<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
    import { page } from "$app/stores";
	import { appMobileView } from "$stores/app";
    import { pageHeader } from "$stores/layout";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageHeader = {
        title: "Settings",
        left: {
            label: "Back",
            url: "/",
        },
        right: {
        }
    };
</script>

<svelte:head>
    <title>Settings</title>
</svelte:head>

<SettingsMenu />