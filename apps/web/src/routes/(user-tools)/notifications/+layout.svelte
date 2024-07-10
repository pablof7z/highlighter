<script lang="ts">
	import { layout, pageHeader, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    $layout = {
        title: "Notifications",
        fullWidth: false,
    }

    onDestroy(() => {
        $layout.fullWidth = undefined;
    });
</script>

<slot />