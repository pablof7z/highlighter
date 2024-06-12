<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
import ModalShell from "$components/ModalShell.svelte";
	import { failedPublishEvents } from "$stores/events";
	import { pluralize } from "$utils";
	import { ndk } from "$stores/ndk.js";
	import Button from "$components/ui/button/button.svelte";
	import { NDKEvent, NDKEventId, NDKRelay, NDKRelaySet } from "@nostr-dev-kit/ndk";

    let retryingId = new Set();

    async function retry(event: NDKEvent, relays?: WebSocket["url"][]) {
        let relaySet: NDKRelaySet | undefined;

        if (relays && relays.length >0) {
            relaySet = NDKRelaySet.fromRelayUrls(relays, $ndk);
        }
        
        retryingId.add(event.id);
        try {
            await event.publish(relaySet);
            if ($ndk.cacheAdapter?.discardUnpublishedEvent)
                $ndk.cacheAdapter.discardUnpublishedEvent(event.id);
            failedPublishEvents.update($failed => {
                $failed.delete(event.id);
                return new Map($failed);
            });
        } finally {
            retryingId.delete(event.id);
            retryingId = retryingId
        }
    }

    function discard(id: NDKEventId) {
        if ($ndk.cacheAdapter?.discardUnpublishedEvent)
            $ndk.cacheAdapter.discardUnpublishedEvent(id);
        failedPublishEvents.update($failed => {
            $failed.delete(id);
            return new Map($failed);
        });
    }
</script>

<ModalShell
    title={`${pluralize($failedPublishEvents.size, "Event")} Failed to Publish`}
    class="max-w-xl w-full"
>
    <div class="flex flex-col items-center justify-center space-y-4 w-full">
        <div class="flex flex-col gap-2 w-full">
            {#each Array.from($failedPublishEvents.values()) as {event, relays, error}}
                <div class="flex flex-row items-center border-y py-4 w-full">
                    <div class="grow flex flex-col gap-1">
                        <span class="grow">{error.message}</span>
                        {#if relays}
                            <div class="text-xs text-muted-foreground">
                                Tried to publish to {relays.length} {pluralize(relays.length, "relay")}.
                            </div>
                        {/if}
                    </div>

                    <Button class="shrink basis-0" on:click={() => retry(event, relays)} disabled={retryingId.has(event.id)}>
                        {#if retryingId.has(event.id)}
                            <span class="spinner spinner-sm"></span>
                        {:else}
                            Retry
                        {/if}
                    </Button>

                    <Button variant="outline" class="shrink basis-0" on:click={() => discard(event.id)}>
                        Dismiss
                    </Button>
                </div>
                <div class="max-h-[25rem] overflow-y-auto text-xs">
                    <EventWrapper ndk={$ndk} {event} expandReplies={false} expandThread={false} showReply={false} />
                </div>
            {/each}
        </div>
    </div>
</ModalShell>