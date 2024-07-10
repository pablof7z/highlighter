<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { Readable } from "svelte/store";

    const zaps = getContext("zaps") as Readable<NDKEvent[]>;
</script>

<div class="discussion-wrapper">
    {#each $zaps as event (event.id)}
        <EventWrapper {event} compact />
    {/each}
</div>
