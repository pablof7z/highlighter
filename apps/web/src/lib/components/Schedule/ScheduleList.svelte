<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
    import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk.js";
	import { NDKEvent, NDKEventId, NDKKind } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import ScheduleListItem from "./ScheduleListItem.svelte";
	import Schedule from "$lib/illustrations/schedule.svelte";
	import { openModal } from "$utils/modal";
	import BlankState from '$components/PageElements/BlankState.svelte';

    type ScheduledEvent = {
        scheduleEvent: NDKEvent;
        event: NDKEvent;
    };
    
    let events: NDKEventStore<NDKEvent>;
    let eventsToPublish: ScheduledEvent[] = [];
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
                        }
                    }
                }

                eventsToPublish = eventsToPublish.sort((a, b) => a.event.created_at! - b.event.created_at!);
            } catch (e) {
                console.error('failed to decrypt event', e);
            }
        })
    }
</script>

<div>
    {#if eventsToPublish.length === 0}
        <BlankState
            cta="Start Creating"
            on:click={() => openModal(NewItemModal)}
            class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
        >
            <Schedule class="w-full h-full opacity-50" />
            You don't yet have any posts scheduled.
            Yet.
        </BlankState>
    {:else}
        <ul class="discussion-wrapper my-6">
            {#each eventsToPublish as { scheduleEvent, event }}
                <li class="discussion-item">
                    <ScheduleListItem {scheduleEvent} {event} />
                </li>
            {/each}
        </ul>
    {/if}
</div>

<style lang="postcss">
    h2 {
        @apply text-foreground text-xl font-medium sticky top-0 z-50 p-6;
    }
</style>