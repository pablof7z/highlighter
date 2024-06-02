<script lang="ts">
	import PageTitle from '$components/PageElements/PageTitle.svelte';
	import { pageHeader } from "$stores/layout";
	import { onDestroy, onMount } from "svelte";
	import { loadedEvent, title } from "$lib/stores/item-view.js";
	import { openModal } from "$utils/modal";
	import Curations from '$components/Curations.svelte';
	import AddToCuration from '$modals/AddToCuration.svelte';
	import { Plus } from 'phosphor-svelte';

    let event;

    $: event = $loadedEvent;

    $: {
        $pageHeader ??= {};
        $pageHeader.right = {
            icon: Plus,
            label: "Add",
            fn: () => {
                openModal(AddToCuration, {
                    event
                });
            }
        }
    }

    onDestroy(() => {
        if ($pageHeader) {
            $pageHeader.right = undefined;
        }
    })
</script>

<PageTitle class="mb-0" title="Curations" defaultTitle={$title} />
<h2 class="mb-4 mt-0 pt-0 text-lg">
    Curations where {$title} is included
</h2>

{#if event}
    <Curations filter={event.filter()} />
{/if}