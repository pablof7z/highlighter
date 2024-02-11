<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
    import { page } from "$app/stores";
    import { pageHeader, pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";
	import MainWrapper from '$components/Page/MainWrapper.svelte';

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
    $pageSidebar = null;

    onDestroy(() => {
        $pageSidebar = null;
    })
</script>

<svelte:head>
    <title>Settings</title>
</svelte:head>

<MainWrapper marginClass="max-w-3xl mx-auto">
    <SettingsMenu />
</MainWrapper>