<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
    import * as Event from "$components/Event";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import TopPlusRecentZaps from "$components/Events/Zaps/TopPlusRecentZaps.svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";

    export let event: NDKEvent;
</script>

<div class="
    bg-secondary rounded
    w-[var(--content-card-width)]
    min-h-[var(--content-card-height)]
    max-h-[calc(var(--content-card-height)*2)]
    p-4
">
    <Event.Header {event} />
    <EventContent ndk={$ndk} {event} />
    <ScrollArea orientation="horizontal">
        <TopPlusRecentZaps {event} />
    </ScrollArea>
</div>