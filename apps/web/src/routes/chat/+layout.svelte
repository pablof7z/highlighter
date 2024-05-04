<script lang="ts">
	import Chat from '$components/PageSidebar/Chat.svelte';
    import { layoutMode, pageHeader, pageSidebar, resetLayout } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $layoutMode = "content-focused";
    $pageSidebar = {
        component: Chat,
        focused: true,
        props: {
            activeUser: undefined
        }
    }
    onDestroy(resetLayout);

    $pageHeader = {
        title: 'Chat',
    }
</script>

<slot />
