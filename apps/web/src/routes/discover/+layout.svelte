<script lang="ts">
	import { layoutMode, resetLayout } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $layoutMode = "full-width";

    onDestroy(resetLayout);
</script>

<slot />