<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { event, event } from "$components/Feed/NoteOld.svelte";
import currentUser from "$stores/currentUser";
	import { ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKEventId, NDKKind } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { encode } from "punycode";
	import ScheduleListItem from "./ScheduleListItem.svelte";

    type ScheduledEvent = {
        scheduleEvent: NDKEvent;
        event: NDKEvent;
    };
    
    let events: NDKEventStore<NDKEvent>;
    let eventsToPublish: ScheduledEvent[] = [];
    let eventsPublished: NDKEvent[] = [];
    const readyEvents = new Set<NDKEventId>();

    $: if ($currentUser && !events) {
        events = $ndk.storeSubscribe({
            kinds: [ NDKKind.DVMEventSchedule ],
            authors: [ $currentUser.pubkey ]
        });
    }

    const now = Math.floor(Date.now() / 1000);

    $: {
        $events.map(async (event) => {
            if (readyEvents.has(event.id)) return;
            readyEvents.add(event.id);
            console.log('decrypting event', event.content, event.rawEvent());
            const pTag = event.tagValue('p');
            const user = $ndk.getUser({pubkey: pTag})
            try {
                await event.decrypt(user);
                const parsed = JSON.parse(event.content);

                for (const el of parsed) {
                    if (el[0] === 'i') {
                        const payload = JSON.parse(el[1]);
                        const e = new NDKEvent($ndk, payload);

                        if (e.created_at! > now) {
                            eventsToPublish.push({ scheduleEvent: event, event: e });
                        } else {
                            eventsPublished.push(e);
                        }
                    }
                }

                eventsToPublish = eventsToPublish.sort((a, b) => a.event.created_at! + b.event.created_at!);
                eventsPublished = eventsPublished.sort((a, b) => a.created_at! - b.created_at!);
            } catch (e) {
                console.error('failed to decrypt event', e);
            }
        })
    }


</script>

<div>
    <h2 class="mobile-nav">Scheduled Events</h2>

    {#if eventsToPublish.length === 0}
        <p>No scheduled posts</p>
    {:else}
        <ul class="discussion-wrapper my-6">
            {#each eventsToPublish as { scheduleEvent, event } (event.id)}
                <li class="discussion-item">
                    <ScheduleListItem {scheduleEvent} {event} />
                </li>
            {/each}
        </ul>
    {/if}
</div>

<div>
    <h2 class="mobile-nav">Published Events</h2>
    
    <ul class="discussion-wrapper my-6">
        {#each eventsPublished as event (event.id)}
            <li class="discussion-item">
                <EventWrapper {event} />
            </li>
        {/each}
    </ul>
</div>


<style lang="postcss">
    h2 {
        @apply text-white text-xl font-medium sticky top-0 z-50 p-6;
    }
</style>