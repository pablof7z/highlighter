<script lang="ts">
    import { page } from "$app/stores";
    import { layoutMode, pageHeader, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageHeader = {
        title: "Drafts",
    }

    $layoutMode = "single-column-focused";

    onDestroy(() => {
        resetLayout();
    })
</script>

<svelte:head>
    <title>Drafts</title>
</svelte:head>

<slot />