<script lang="ts">
	import { Export } from 'phosphor-svelte';
	import ShareModal from '$modals/ShareModal.svelte';
	import Highlights from "$components/Highlights.svelte";
	import { openModal } from '$utils/modal';
	import { pageHeader } from '$stores/layout';
	import { onDestroy } from 'svelte';

    let event;

    $: {
        $pageHeader ??= {};
        $pageHeader.title = "Highlights";
        $pageHeader.right = {
            icon: Export,
            fn: () => {
                openModal(ShareModal, { event });
            }
        }
    }

    onDestroy(() => {
        if ($pageHeader?.right) $pageHeader.right = undefined;
    })
</script>

{#if event}
    <Highlights filter={event.filter()} />
{/if}
