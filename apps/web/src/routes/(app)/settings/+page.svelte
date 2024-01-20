<script lang="ts">
    import { page } from "$app/stores";
    import { pageSidebar } from "$stores/layout";
    import Settings from "$components/PageSidebar/Settings.svelte";
	import NetworkSettings from "./NetworkSettings.svelte";
	import { onDestroy } from "svelte";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageSidebar = {
        component: Settings,
        props: {}
    }

    onDestroy(() => {
        $pageSidebar = null;
    })
</script>

<div class="p-6">
    {#if id === "network"}
        <NetworkSettings />
    {/if}
</div>