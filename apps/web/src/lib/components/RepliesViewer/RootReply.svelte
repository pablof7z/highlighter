<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { NDKKind, type NDKEvent, type NDKFilter } from "@nostr-dev-kit/ndk";
    import { ndk } from "@kind0/ui-common";
    import { EventThread } from "@nostr-dev-kit/ndk-svelte-components";
	import { derived } from "svelte/store";

    export let event: NDKEvent;
    let showComment = false;

    // Filter for replies to
    const filters: NDKFilter[] = [ { kinds: [NDKKind.GroupReply], ...event.filter() } ];

    let rootEventId = event.getMatchingTags("a").find(t => t[3] === "root")?.[1];
    if (rootEventId) { filters.push({ "#a": [rootEventId] }); }

    rootEventId ??= event.getMatchingTags("e").find(t => t[3] === "root")?.[1];

    const allReplies = $ndk.storeSubscribe(filters,
        { subId: "all-replies", groupable: false }
    );

    function eventIsReplyTo(event: NDKEvent, desiredEvent: NDKEvent) {
        // return true;
        const isIt = !!event.getMatchingTags("e").find((t) => (
            t[1] === desiredEvent.id &&
            t[3] === "reply"
        ))
        console.log("eventIsReplyTo", event.content, desiredEvent.content, {isIt}, event.getMatchingTags("e"), desiredEvent.id);
        return !!event.getMatchingTags("e").find((t) => (
            t[1] === desiredEvent.id &&
            t[3] === "reply"
        ));
    }
</script>

<EventThread
    ndk={$ndk}
    {event}
    eventComponent={EventWrapper}
    eventComponentProps={{class: "!bg-white discussion-item opacity-50"}}
    class="discussion-item"
/>

<!-- {#if showComment}
    <Comment {event} />
{/if} -->

<style lang="postcss">
    :global(.event-thread) {
        @apply w-full;
    }

    :global(.connector) {
        @apply border-l border-neutral-800;
        @apply border-b border-neutral-800;
    }
</style>