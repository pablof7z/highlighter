<script lang="ts">
    import { page } from "$app/stores";
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
