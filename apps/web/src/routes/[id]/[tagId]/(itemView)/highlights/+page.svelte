<script lang="ts">
	import PageTitle from '$components/PageElements/PageTitle.svelte';
	import { Export } from 'phosphor-svelte';
	import ShareModal from '$modals/ShareModal.svelte';
	import Highlights from "$components/Highlights.svelte";
	import { loadedEvent, title } from "$lib/stores/item-view.js";
	import { openModal } from '$utils/modal';
	import { pageHeader } from '$stores/layout';
	import { onDestroy } from 'svelte';

    let event;

    $: event = $loadedEvent;

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
