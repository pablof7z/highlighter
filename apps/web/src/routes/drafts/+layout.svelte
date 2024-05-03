<script lang="ts">
	import DraftsMenu from '$components/Drafts/Menu.svelte';
    import { page } from "$app/stores";
    import { detailView, layoutMode, pageHeader, pageSidebar, resetLayout } from "$stores/layout";
    import Drafts from "$components/PageSidebar/Drafts.svelte";
	import { onDestroy } from "svelte";
	import { reset } from '$stores/post-editor';

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageHeader = {
        title: "Drafts",
    }

    $layoutMode = "list-column";
    $detailView = {
        component: DraftsMenu,
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