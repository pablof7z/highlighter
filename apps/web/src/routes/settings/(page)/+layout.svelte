<script lang="ts">
	import Settings from '$components/PageSidebar/Settings.svelte';
    import { pageSidebar } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $pageSidebar = {
        component: Settings,
        props: {
            sidebarView: true
        }
    }

    onDestroy(() => { $pageSidebar = null; })
</script>

<slot />
