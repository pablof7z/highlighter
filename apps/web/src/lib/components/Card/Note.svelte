<script lang="ts">
    import { NDKEvent } from "@nostr-dev-kit/ndk";
    import * as Event from "$components/Event";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { ndk } from "$stores/ndk";
	import TopPlusRecentZaps from "$components/Events/Zaps/TopPlusRecentZaps.svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { getEventUrl } from "$utils/url";

    export let event: NDKEvent;
</script>

<div class="
    bg-secondary rounded
    w-[var(--content-card-width)]
    min-h-[var(--content-card-height)]
    max-h-[calc(var(--content-card-height)*2)]
    flex flex-col divide-y divide-background
">
    <div class="p-4 pb-1">
        <Event.Header {event} />

    </div>
    <a
        href={getEventUrl(event)}
        class="p-4 break-words whitespace-normal grow cursor-pointer">
        <EventContent ndk={$ndk} {event} />
    </a>
    <div class="p-4">
        <div class="p-4 flex flex-row flex-nowrap overflow-x-auto scrollbar-hide">
            <TopPlusRecentZaps {event} />
        </div>
    </div>
</div>