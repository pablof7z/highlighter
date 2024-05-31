<script lang="ts">
    import { layoutMode, pageHeader, resetLayout } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $layoutMode = "full-width";
    onDestroy(resetLayout);

    $pageHeader = {
        title: 'Chat',
    }
</script>

<slot />
