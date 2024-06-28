<script lang="ts">
	import WithItem from "$components/Event/ItemView/WithItem.svelte";
	import { goto } from "$app/navigation";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { pageHeader } from "$stores/layout";

    export let id: string;

    const canNavigateBack = () => {
        return window.history.length > 1;
    }

    $pageHeader = {
        title: "Thread",
        left: {
            label: 'Back',
            fn: () => canNavigateBack() ? window.history.back() : goto('/')
        }
    }
</script>

{#key id}
    <WithItem tagId={id} let:event>
        {#if event}
            <ItemView {event} ignoreHeader={true}  />
        {/if}
    </WithItem>
{/key}
