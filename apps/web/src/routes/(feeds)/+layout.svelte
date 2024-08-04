<script lang="ts">
	import { onDestroy } from "svelte";
	import { layout, layoutMode, pageHeader, resetLayout } from "$stores/layout";
	import { appMobileView } from "$stores/app";

    $layout.fullWidth = true;
    
    onDestroy(() => {
        resetLayout();
    });
</script>

<div class="lg:p-6">
    <slot />
</div>