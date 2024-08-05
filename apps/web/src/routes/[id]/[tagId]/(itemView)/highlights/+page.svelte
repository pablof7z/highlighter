<script lang="ts">
	import { Export } from 'phosphor-svelte';
	import ShareModal from '$modals/ShareModal.svelte';
	import Highlights from "$components/Highlights.svelte";
	import { openModal } from '$utils/modal';
	import { layout } from '$stores/layout';
	import { onDestroy } from 'svelte';

    let event;

    $: {
        $layout.title = "Highlights";
        $layout.options = [{
            icon: Export,
            fn: () => {
                openModal(ShareModal, { event });
            }
        }]
    }
</script>

{#if event}
    <Highlights filter={event.filter()} />
{/if}
