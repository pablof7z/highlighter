<script lang="ts">
	import MediaCollection from "$components/Events/MediaCollection.svelte";
	import FeedEventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "$stores/ndk.js";
    import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
</script>

<FeedEventWrapper {event} class={$$props.class??""}>
    <EventContent
        ndk={$ndk}
        {event}
        showEntire={true}
        maxLength={9999}
        mediaCollectionComponent={MediaCollection}
    />
</FeedEventWrapper>

<style lang="postcss">
    :global(.event-content .note-media--wrapper) {
        @apply flex grid-flow-col gap-6 overflow-x-auto h-96 justify-start items-start flex-nowrap w-full pb-4;
    }

    :global(.event-content .note-media--wrapper > *) {
        @apply !w-96 h-full object-cover object-left-top rounded-lg;
    }
</style>