<script lang="ts">
	import { onDestroy } from "svelte";
	import { Article, Lightning, Note, Notepad } from "phosphor-svelte";
	import { layoutMode, pageHeader, pageNavigationOptions, resetLayout } from "$stores/layout";
	import PageHeader from "$views/HomeLayout/PageHeader.svelte";

    $layoutMode = "full-width";
    
    onDestroy(() => {
        resetLayout();
    });

    $pageHeader = {
        component: PageHeader,
    };
</script>

<slot />