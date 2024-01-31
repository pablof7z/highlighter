<script lang="ts">
    import { page } from "$app/stores";
    import { pageSidebar } from "$stores/layout";
    import Drafts from "$components/PageSidebar/Drafts.svelte";
	import { onDestroy } from "svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";

    let id: string;

    $: id = $page.url.search?.substring(1);

    $pageSidebar = { component: Drafts, props: {} }
    onDestroy(() => { $pageSidebar = null; })
</script>

<MainWrapper marginClass="max-w-3xl">
    <slot />
</MainWrapper>