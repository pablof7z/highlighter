<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import currentUser from '$stores/currentUser';
    import { DraftCheckpoint, drafts, DraftItem as DraftItemType } from "$stores/drafts";
	
	import { openModal } from '$utils/modal';
	import BlankState from '$components/PageElements/BlankState.svelte';
	
    
	
	import { ndk } from '$stores/ndk';
	import { NDKDraft, NDKEvent, NDKKind, NDKSubscription, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
	import { mainContentKinds } from '$utils/event';
	import { onDestroy } from 'svelte';
	import { getDefaultRelaySet } from '$utils/ndk';
    import { toast } from "svelte-sonner";
	import { layout } from '$stores/layout';

    import * as Studio from '$components/Studio';

	$layout.back = { url: "/" };
	$layout.navigation = false;

    const relaySet = getDefaultRelaySet();

    const relayDraftEvents: Record<string, NDKEvent> = {};
    
    let relayDrafts: NDKSubscription | undefined;
        
    if ($currentUser) {
        relayDrafts = $ndk.subscribe({
            kinds: [NDKKind.Draft], "#k": mainContentKinds.map(k => k.toString()), authors: [$currentUser.pubkey]
        }, { subId: 'drafts', cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY }, relaySet);
        relayDrafts.on("event", async (event: NDKEvent) => {
            const draft = await (NDKDraft.from(event)).getEvent();
            const dTag = event.dTag;

            // make sure we have a d-tag
            if (!dTag) return;

            if (relayDraftEvents[dTag]?.created_at! > event.created_at!) return;

            relayDraftEvents[dTag] = event;

            try {
                let existingDraft: DraftItemType = $drafts.find(d => d.id === dTag) || {
                    id: dTag,
                    checkpoints: "[]",
                    type: "article"
                }

                const checkpoints = JSON.parse(existingDraft?.checkpoints || "[]") as DraftCheckpoint[];

                // check if we already have this draft by checking the eventId
                if (checkpoints.find(c => c.eventId === event.id)) return;

                // insert the draft in the right place according to the time of each checkpoint
                let insertIndex: number = 0;
                for (const checkpoint of checkpoints) {
                    // if (Math.floor(checkpoint.time/1000) <= event.created_at!) {
                    //     break;
                    if (checkpoint.time > event.created_at!) {
                        insertIndex++;
                    }
                }

                const checkpoint: DraftCheckpoint = {
                    time: event.created_at! * 1000,
                    manuallySaved: true,
                    data: { event: JSON.stringify(draft.rawEvent()), preview: "" },
                    eventId: event.id,
                    relay: event.relay?.url
                };

                // check if the item at this index has the same time, if it is, replace
                // if (checkpoints[insertIndex] && Math.floor(checkpoints[insertIndex].time/1000) === checkpoint.time) {
                //     checkpoints[insertIndex] = checkpoint;
                // } else {
                    checkpoints.splice(insertIndex, 0, checkpoint);
                // }

                existingDraft = {
                    ...existingDraft,
                    checkpoints: JSON.stringify(checkpoints),
                };

                $drafts = [...$drafts.filter(d => d.id !== dTag), existingDraft];
            } catch {}
        });
        relayDrafts.start();
    }

    onDestroy(() => {
        relayDrafts?.stop();
    });
</script>

{#if $drafts.length === 0}
    <BlankState
        cta="Start making one"
        on:click={() => openModal(NewItemModal)}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
    >
        <img src="/images/drafts.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <blockquote slot="afterCta" class="app-quote relative my-8">
            <p class="z-1 relative text-muted-foreground text-lg font-serif">
                “And what can life be worth if the first rehearsal for life is life itself? That is why life is always like a sketch. No, "sketch" is not quite a word, because a sketch is an outline of something, the groundwork for a picture, whereas the sketch that is our life is a sketch for nothing, an outline with no picture.”
            </p>

            <div class="author">
                Milan Kundera
            </div>
        </blockquote>
        
        <span class="text-2xl font-semibold">Life is always a draft,</span>
        <br>
        <span class="font-light text-muted-foreground">but you don't have one here.</span>
    </BlankState>
{:else if $currentUser}
    <Studio.Drafts.List.Shell>

    </Studio.Drafts.List.Shell>
{/if}
