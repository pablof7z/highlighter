<script lang="ts">
	import { goto } from "$app/navigation";
	import ItemView from "$components/Event/ItemView/ItemView.svelte";
	import { pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, filterFromId } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { afterUpdate } from "svelte";

    export let id: string;

    const filter = filterFromId(id);
    let event: NDKEventStore<NDKEvent>;
    let loading = false;
    let eosed = false;
        
    afterUpdate(() => {
        event = $ndk.storeSubscribe(filter, { subId: 'event-viewer', closeOnEose: true, groupable: false });
        event.onEose(() => { eosed = true; });
        
        // if we are still loading after 1 second, show the loading screen
        setTimeout(() => { loading = true; }, 1000);
    });

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

{#if event && $event[0]}
    <ItemView event={$event[0]} ignoreHeader={true}  />
{:else if eosed}
    <p>Unable to find the event.</p>
{:else if loading}
    <p>Still looking for the event...</p>
{/if}