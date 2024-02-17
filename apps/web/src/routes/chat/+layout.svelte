<script lang="ts">
	import Chat from '$components/PageSidebar/Chat.svelte';
    import { pageHeader, pageSidebar } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $pageSidebar = {
        component: Chat,
        props: {
            activeUser: undefined
        }
    }
    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: 'Chat',
    }
</script>

<slot />
