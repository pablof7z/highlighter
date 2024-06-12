<script lang="ts">
	import NewItemModal from '$modals/NewItemModal.svelte';
	import currentUser from '$stores/currentUser';
    import { DraftCheckpoint, drafts, DraftItem as DraftItemType } from "$stores/drafts";
	import { Timer, Trash } from "phosphor-svelte";
	import DraftItem from "$components/Creator/DraftItem.svelte";
	import DraftListVersionItem from "$components/Creator/DraftListVersionItem.svelte";
	import PageTitle from '$components/PageElements/PageTitle.svelte';
	import { openModal } from '$utils/modal';
	import BlankState from '$components/PageElements/BlankState.svelte';
	import { appMobileHideNewPostButton } from '$stores/app';
    import { pageHeader } from '$stores/layout';
	import RelativeTime from '$components/PageElements/RelativeTime.svelte';
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import { Button } from '$components/ui/button';
	import { ndk } from '$stores/ndk';
	import { NDKDraft, NDKEvent, NDKKind, NDKSubscription, NDKSubscriptionCacheUsage } from '@nostr-dev-kit/ndk';
	import { mainContentKinds } from '$utils/event';
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { onDestroy } from 'svelte';
	import { derived, writable } from 'svelte/store';
	import { getDefaultRelaySet } from '$utils/ndk';
    import { toast } from "svelte-sonner";

    const relaySet = getDefaultRelaySet();

	$pageHeader = { title: 'Drafts' }

    $appMobileHideNewPostButton = true;

    const relayDraftEvents: Record<string, NDKEvent> = {};
    
    function trash(id: string) {
        $drafts = $drafts.filter(d => d.id !== id);

        if (!relayDraftEvents[id]) return;

        const event = relayDraftEvents[id];

        toast.success("Draft deleted", {
            description: "Will delete the draft from relays",
            duration: 5000,
            action: {
                label: "Stop",
                onClick: () => {
                    toast.success("Draft won't be deleted from relays", {
                        description: event.relay ? `Draft will remain in ${event.relay.url}` : undefined,
                        duration: 5000
                    });
                }
            },
            onAutoClose: async () => {
                event.content = "";
                event.publishReplaceable(relaySet);
                const del = await event.delete(undefined, false);
                del.publish(relaySet);
            }
        });
    }

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

{#if $drafts.length > 0}
    <PageTitle title="Drafts" />
{/if}

{#if $drafts.length === 0}
    <BlankState
        cta="Start making one"
        on:click={() => openModal(NewItemModal)}
        class="md:fixed md:top-1/2 md:-translate-y-1/2 md:left-1/2 md:-translate-x-1/2"
    >
        <img src="/images/drafts.png" class="mx-auto w-3/5 h-3/5 opacity-60 my-8" />
        <blockquote slot="afterCta" class="app-quote relative my-8">
            <p class="z-1 relative text-muted-foreground text-lg font-[Filosofia]">
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
    <ul class="w-full discussion-wrapper">
        {#key $drafts}
            {#each $drafts as draft (draft.id)}
                <div class="discussion-item">
                <div class="max-h-[25vh] overflow-hidden">
                    <DraftItem item={draft} />
                </div>
                <div class="flex flex-row justify-between items-center">
                    <Button variant="secondary" class="gap-0 flex flex-row items-center group whitespace-nowrap" on:click={() => trash(draft.id)}>
                        <Trash class="w-5 h-5" weight="light" />
                        <span class="max-w-0 truncate group-hover:max-w-[5rem] text-foreground whitespace-nowrap line-clamp-1 ml-2 transition-all duration-300">
                            Delete
                        </span>
                    </Button>

                    <DropdownMenu.Root>
                        <DropdownMenu.Trigger asChild let:builder>
                            <Button builders={[builder]} variant="outline">
                                Versions
                                <Timer class="w-5 h-5" />
                            </Button>
                        </DropdownMenu.Trigger>

                        <DropdownMenu.Content class="absolute z-[999999]">
                            <DropdownMenu.Group>
                                {#each JSON.parse(draft.checkpoints) as checkpoint}
                                    <DropdownMenu.Item>
                                        <DraftListVersionItem {draft} {checkpoint} />
                                    </DropdownMenu.Item>
                                {/each}
                            </DropdownMenu.Group>
                        </DropdownMenu.Content>
                    </DropdownMenu.Root>
                </div>
                <div class="text-xs font-light opacity-50 text-center w-full">
                    <RelativeTime timestamp={JSON.parse(draft.checkpoints)[0].time} />
                </div>
                </div>
            {/each}
        {/key}
    </ul>
{/if}
