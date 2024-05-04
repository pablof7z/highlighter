<script lang="ts">
	import ScheduleList from "$components/Schedule/ScheduleList.svelte";
	import { detailView, layoutMode, pageSidebar, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    $layoutMode = "single-column-focused";

    $pageSidebar = {
        component: ScheduleList,
        focused: true,
        props: {}
    }

    onDestroy(resetLayout);
</script>

<slot />