<script lang="ts">
	import DraftsMenu from '$components/Drafts/Menu.svelte';
    import { page } from "$app/stores";
    import { pageHeader, pageSidebar } from "$stores/layout";
    import Drafts from "$components/PageSidebar/Drafts.svelte";
	import { onDestroy } from "svelte";
	import MainWrapper from '$components/Page/MainWrapper.svelte';

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageSidebar = {
        component: Drafts,
        props: {}
    }

    $pageHeader = {
        title: "Drafts",
    }

    onDestroy(() => {
        $pageSidebar = null;
    })
</script>

<svelte:head>
    <title>Drafts</title>
</svelte:head>

<MainWrapper class="sm:hidden">
    <DraftsMenu />
</MainWrapper>