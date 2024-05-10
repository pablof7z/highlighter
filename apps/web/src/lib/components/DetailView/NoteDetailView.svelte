<script lang="ts">
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import EventWrapper from "$components/Feed/EventWrapper.svelte";

    export let event: NDKEvent;
</script>

<EventWrapper
    {event}
    expandThread={true}
    expandReplies={true}
    showReply={false}
/>