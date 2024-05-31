<script lang="ts">
	import { layoutMode, resetLayout } from "$stores/layout";
	import { onDestroy } from "svelte";

    $layoutMode = "single-column-focused";

    onDestroy(resetLayout);
</script>

<slot />