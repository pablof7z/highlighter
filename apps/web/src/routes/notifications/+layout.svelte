<script lang="ts">
	import { pageHeader, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    $pageHeader = {
        title: "Notifications",
    }

    onDestroy(resetLayout);
</script>

<slot />