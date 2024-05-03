<script lang="ts">
    import { page } from "$app/stores";
    import { pageHeader, pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";

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
