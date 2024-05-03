<script lang="ts">
	import Chat from '$components/PageSidebar/Chat.svelte';
    import { detailView, layoutMode, pageHeader, pageSidebar, resetLayout } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $layoutMode = 'list-column';
    $detailView = {
        component: Chat,
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
