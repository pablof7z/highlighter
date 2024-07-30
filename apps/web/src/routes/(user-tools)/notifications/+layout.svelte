<script lang="ts">
	import { layout, pageHeader, resetLayout } from "$stores/layout";
	import { notifications } from "$stores/notifications";
	import { onDestroy } from "svelte";

    $layout = {
        title: "Notifications",
        fullWidth: false,
        back: { url: "/" }
    }

    onDestroy(() => {
        $layout.fullWidth = undefined;
    });
</script>

{#if $notifications}
    <slot />
{/if}