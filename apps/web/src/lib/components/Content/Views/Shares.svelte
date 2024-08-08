<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy } from "svelte";
	import { derived, Readable } from "svelte/store";
	import { WrappedEvent } from "../../../../app";
	import { ndk } from "$stores/ndk";

    export let wrappedEvent = getContext("wrappedEvent") as WrappedEvent;

    const _shares = $ndk.storeSubscribe([
        {"#q": [wrappedEvent.tagId()]},
        {kinds: [NDKKind.Text], ...wrappedEvent.filter()},
    ])

    const shares = derived(_shares, $shares => {
        const s = [];

        for (const share of $shares) {
            if (share.getMatchingTags("a", "mention").some(t => t[1] === wrappedEvent.tagId()))
                s.push(share);

            else if (share.getMatchingTags("q").some(t => t[1] === wrappedEvent.tagId()))
                s.push(share);
        }

        return s;
    });

    onDestroy(() => { _shares.unsubscribe() })
</script>

<div class="discussion-wrapper">
    {#each $shares as event (event.id)}
        <EventWrapper {event} compact />
    {/each}
</div>