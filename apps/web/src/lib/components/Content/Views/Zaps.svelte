<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy } from "svelte";
	import { WrappedEvent } from "../../../../app";
	import { ndk } from "$stores/ndk";

    export let wrappedEvent = getContext("wrappedEvent") as WrappedEvent;

    const zaps = $ndk.storeSubscribe([
        { kinds: [NDKKind.Zap], ...wrappedEvent.filter()},
        { kinds: [NDKKind.Nutzap], ...wrappedEvent.filter()},
    ])

    onDestroy(() => { zaps.unsubscribe() })
</script>

<div class="discussion-wrapper">
    {#each $zaps as event (event.id)}
        <EventWrapper {event} compact />
    {/each}
</div>
