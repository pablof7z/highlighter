<script lang="ts">
	import { layoutMode, resetLayout } from '$stores/layout.js';
	import { layoutNavState } from "$stores/layout";
	import { onDestroy } from 'svelte';

    $layoutNavState = 'collapsed';
    $layoutMode = "full-width";

    onDestroy(resetLayout);
</script>

<slot />