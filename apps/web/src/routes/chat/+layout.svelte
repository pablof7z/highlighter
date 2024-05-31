<script lang="ts">
    import { layoutMode, pageHeader, resetLayout } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $layoutMode = "content-focused";
    onDestroy(resetLayout);

    $pageHeader = {
        title: 'Chat',
    }
</script>

<slot />
