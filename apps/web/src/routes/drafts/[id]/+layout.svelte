<script lang="ts">
    import { page } from "$app/stores";
    import { pageSidebar } from "$stores/layout";
	import { onDestroy } from "svelte";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageSidebar.focused = false;
</script>

<slot />