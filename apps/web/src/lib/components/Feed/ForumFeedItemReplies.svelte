<script lang="ts">
	import { getDefaultRelaySet } from "$utils/ndk";
	import { ndk } from "$stores/ndk.js";
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
    import { Readable, derived } from "svelte/store";
	import ForumFeedItem from "./ForumFeedItem.svelte";
	import { getThreadStore } from "./replies";
	import EventWrapper from "./EventWrapper.svelte";

    export let event: NDKEvent;

    const hTag = event.tagValue("h");
    const events = $ndk.storeSubscribe(
        { "#e": [event.id], "#h": [hTag!] },
        { relaySet: getDefaultRelaySet() }
    );

    const threads = getThreadStore(event, events);

    onDestroy(() => {
        events?.unsubscribe();
    });
</script>

{#each $threads as thread, i (thread.id)}
    <EventWrapper event={thread} />
{/each}