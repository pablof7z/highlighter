<script lang="ts">
	import { onDestroy } from 'svelte';
	import { pageSidebar } from "$stores/layout";
	import { NDKList, type NDKEvent } from "@nostr-dev-kit/ndk";
    import ListSidebar from "$components/PageSidebar/List.svelte";

    export let event: NDKEvent;
    export let list = NDKList.from(event);

    $pageSidebar = {
        component: ListSidebar,
        props: { list }
    }

    onDestroy(() => {
        pageSidebar.set(null);
    });
</script>

