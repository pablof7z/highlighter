<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { derived, Readable } from "svelte/store";
	import { WrappedEvent } from "../../../../app";

    export let wrappedEvent = getContext("wrappedEvent") as WrappedEvent;
    const replies = getContext("replies") as Readable<NDKEvent[]>;

    const tagsConsideredOps = new Set<string>();

    for (const tag of wrappedEvent.tags) {
        if (tag[0] === "e" || tag[0] === "u") {
            tagsConsideredOps.add(tag);
        }
    }

    tagsConsideredOps.add(wrappedEvent.id);
    tagsConsideredOps.add(wrappedEvent.tagId())
    
    // Determines whether a reply is an OP
    function isOp(event: NDKEvent) {
        return true;
        for (const tag of event.tags) {
            if (tag[0] === "e" || tag[0] === "u") {
                if (!tagsConsideredOps.has(tag)) {
                    return false;
                }
            }
        }

        return true;
    }

    const onlyOps = derived(replies, $replies =>
        $replies.filter(isOp)
    )
</script>

<div class="discussion-wrapper">
    {#each $onlyOps as event (event.id)}
        <EventWrapper {event} compact />
    {/each}
</div>