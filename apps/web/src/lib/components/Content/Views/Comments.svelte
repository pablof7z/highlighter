<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { getContext } from "svelte";
	import { derived, Readable } from "svelte/store";
	import { WrappedEvent } from "../../../../app";
    import * as Card from "$components/ui/card";
	import { Button } from "$components/ui/button";
	import { isEventShare } from "$utils/event";
    import * as Composer from "$components/Composer";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import currentUser from "$stores/currentUser";

    export let wrappedEvent = getContext("wrappedEvent") as WrappedEvent;
    const replies = getContext("replies") as Readable<NDKEvent[]>;

    const tagsConsideredOps = new Set<string>();

    for (const tag of wrappedEvent.tags) {
        if (tag[0] === "e" || tag[0] === "u") {
            tagsConsideredOps.add(tag);
        }
    }

    tagsConsideredOps.add(wrappedEvent.id);
    tagsConsideredOps.add(wrappedEvent.tagId())
    
    // Determines whether a reply is an OP
    function isOp(event: NDKEvent) {
        for (const tag of event.tags) {
            if (tag[0] === "e" || tag[0] === "u") {
                if (!tagsConsideredOps.has(tag)) {
                    return false;
                }
            }
        }

        return true;
    }

    

    const onlyOps = derived(replies, $replies =>
        $replies
            .filter(isOp)
            .filter(e => !isEventShare(e, wrappedEvent))
    )

    let showComment = false;
</script>

<div class="flex flex-row justify-between items-center border-y border-border px-2 py-4 w-full">
    <h2 class="grow mb-0">Comments</h2>

    <Button on:click={() => showComment = !showComment}>
        Write a comment
    </Button>
</div>

{#if showComment && $currentUser}
    <Composer.Root
        replyTo={wrappedEvent}
        let:state
        let:actionButtons
        let:secondaryButtons
    >
        <Card.Root>
            <Card.Content class="p-4">
                <Composer.Editor {state} />
                <Composer.Attachments {state} />
            </Card.Content>
            <Card.Footer class="flex justify-between w-full">
                <div class="grow">
                    <HorizontalOptionsList options={secondaryButtons} />
                </div>
                <div class="shrink">
                    <HorizontalOptionsList options={actionButtons} />
                </div>
            </Card.Footer>  
        </Card.Root>
    </Composer.Root>
{/if}

<div class="flex flex-col gap-4">
    {#each $onlyOps as event (event.id)}
        <Card.Root>
            <EventWrapper {event} compact skipRoot />
        </Card.Root>
    {/each}
</div>