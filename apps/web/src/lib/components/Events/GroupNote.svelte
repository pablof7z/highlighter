<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "@kind0/ui-common";
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
    <EventContent {event} ndk={$ndk} class="text-lg text-base-100-content/20" />
</EventWrapper>