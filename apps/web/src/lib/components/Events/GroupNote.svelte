<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "$stores/ndk.js";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
    export let urlPrefix: string = "/e/";
</script>

<EventWrapper
    {event}
    skipFooter={true}
    skipReply={true}
    expandReplies={false}
    showReply={false}
    {urlPrefix}
>
    <EventContent {event} ndk={$ndk} class="text-lg text-foreground/20" />
</EventWrapper>