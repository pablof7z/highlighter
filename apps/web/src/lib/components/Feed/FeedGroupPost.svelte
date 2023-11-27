<script lang="ts">
	import MediaCollection from "$components/Events/MediaCollection.svelte";
	import FeedEvent from "$components/FeedEvent.svelte";
	import { ndk } from "@kind0/ui-common";
    import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
</script>

<FeedEvent {event} suffixUrl={event.id.slice(0, 18)}>
    <EventContent ndk={$ndk} {event} showEntire={true} maxLength={9999} mediaCollectionComponent={MediaCollection} />
</FeedEvent>

<style lang="postcss">
    :global(.event-content .note-media--wrapper) {
        @apply flex grid-flow-col gap-6 overflow-x-auto h-96 justify-start items-start flex-nowrap w-full pb-4;

        & > * {
            @apply !w-96 h-full object-cover object-left-top rounded-lg;
        }
    }
</style>