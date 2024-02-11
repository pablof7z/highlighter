<script lang="ts">
	import { page } from '$app/stores';
	import Chat from '$components/PageSidebar/Chat.svelte';
    import { pageHeader, pageSidebar } from '$stores/layout.js';
	import { onDestroy } from 'svelte';

    $pageSidebar = {
        component: Chat,
        props: {
            activeUser: $page.data.user,
        }
    }

    onDestroy(() => { $pageSidebar = null; })

    $pageHeader = {
        title: 'Chat',
    }
</script>

<slot />
