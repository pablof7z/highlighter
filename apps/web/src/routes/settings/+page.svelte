<script lang="ts">
	import SettingsMenu from '$components/Settings/Menu.svelte';
    import { page } from "$app/stores";
    import { pageHeader, pageSidebar } from "$stores/layout";
    import Settings from "$components/PageSidebar/Settings.svelte";
	import { onDestroy } from "svelte";
	import MainWrapper from '$components/Page/MainWrapper.svelte';

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageSidebar = {
        component: Settings,
        props: {}
    }

    onDestroy(() => {
        $pageSidebar = null;
    })

    $pageHeader = {
        title: "Settings",
    }
</script>

<MainWrapper class="sm:hidden">
    <SettingsMenu />
</MainWrapper>