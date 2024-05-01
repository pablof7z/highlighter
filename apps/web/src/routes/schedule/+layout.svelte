<script lang="ts">
	import ScheduleList from "$components/Schedule/ScheduleList.svelte";
	import { detailView, layoutMode, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    $layoutMode = "reversed-columns";

    $detailView = {
        component: ScheduleList,
        props: {}
    }

    onDestroy(resetLayout);
</script>

<slot />