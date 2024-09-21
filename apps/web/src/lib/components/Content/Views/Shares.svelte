<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { derived, Readable } from "svelte/store";
	import { WrappedEvent } from "../../../../app";
    import * as Card from "$components/ui/card";
	import { Button } from "$components/ui/button";
	import { ArrowsClockwise } from "phosphor-svelte";

    export let wrappedEvent = getContext("wrappedEvent") as WrappedEvent;
    const shares = getContext("shares") as Readable<NDKEvent[]>;

    const tagsConsideredOps = new Set<string>();

    for (const tag of wrappedEvent.tags) {
        if (tag[0] === "e" || tag[0] === "u") {
            tagsConsideredOps.add(tag);
        }
    }

    tagsConsideredOps.add(wrappedEvent.id);
    tagsConsideredOps.add(wrappedEvent.tagId())
</script>

<div class="flex flex-row justify-between items-center border-y border-border px-2 py-4 w-full">
    <h2 class="grow mb-0">Shares</h2>
{$shares.length}
    <Button>
        <ArrowsClockwise class="mr-2" />
        Share
    </Button>
</div>

<div class="flex flex-col gap-4">
    {#each $shares as event (event.id)}
        <Card.Root>
            <EventWrapper {event} compact />
        </Card.Root>
    {/each}
</div>