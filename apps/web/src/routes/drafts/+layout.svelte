<script lang="ts">
	import DraftsMenu from '$components/Drafts/Menu.svelte';
    import { page } from "$app/stores";
    import { detailView, layoutMode, pageHeader, pageSidebar, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageHeader = {
        title: "Drafts",
    }

    $layoutMode = "content-focused";
    $pageSidebar = {
        component: DraftsMenu,
        focused: true,
        props: {}
    }

    onDestroy(() => {
        resetLayout();
    })
</script>

<svelte:head>
    <title>Drafts</title>
</svelte:head>

<slot />