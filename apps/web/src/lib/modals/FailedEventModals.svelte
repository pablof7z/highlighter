<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
import ModalShell from "$components/ModalShell.svelte";
	import { failedPublishEvents } from "$stores/events";
	import { pluralize } from "$utils";
	import { ndk } from "$stores/ndk.js";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    let retryingId = new Set();

    async function retry(event) {
        retryingId.add(event.id);
        try {
            await event.publish();
        } finally {
            retryingId.delete(event.id);
        }
    }
</script>

<ModalShell color="glassy" class="max-w-xl w-full">
    <div class="flex flex-col items-center justify-center space-y-4 w-full">
        <h1 class="">
            {pluralize($failedPublishEvents.size, "Event")}
            Failed to Publish
        </h1>

        <div class="flex flex-col gap-2 w-full">
            {#each Array.from($failedPublishEvents.values()) as {event, error}}
                <div class="alert alert-error py-0">
                    {error.message}

                    <button class="btn btn-ghost shrink basis-0" on:click={() => retry(event)} disabled={retryingId.has(event.id)}>
                        {#if retryingId.has(event.id)}
                            <span class="spinner spinner-sm"></span>
                        {:else}
                            Retry
                        {/if}
                    </button>
                </div>
                <EventContent ndk={$ndk} {event} />
            {/each}
        </div>
    </div>
</ModalShell>