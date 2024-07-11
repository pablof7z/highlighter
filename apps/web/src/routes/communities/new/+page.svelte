<script lang="ts">
	import { onDestroy } from 'svelte';
	import { layout } from "$stores/layout";

    $layout.sidebar = false;
    $layout.fullWidth = false;
    onDestroy(() => {
        $layout.sidebar = undefined;
        $layout.fullWidth = undefined;
    })
</script>

<h1>
    New Community
</h1>