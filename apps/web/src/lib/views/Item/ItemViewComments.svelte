<script lang="ts">
	import NewPostModal from "$modals/NewPostModal.svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import BlankState from "$components/PageElements/BlankState.svelte";
	import StylishContainer from "$components/PageElements/StylishContainer.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import NoComments from "$lib/illustrations/no-comments.svelte";
	import { isDirectReply } from "$utils/event";
	import { openModal } from "$utils/modal";
	import { UnsubscribableStore, ZapInvoiceWithEvent, getTopZapsByIndividualAmount } from "$utils/zaps";
	import { NDKEvent, NDKKind, NDKZapInvoice } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Lightning } from "phosphor-svelte";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";
	import { ndk } from "$stores/ndk";

    export let event: NDKEvent;

    const replies = $ndk.storeSubscribe([
        { kinds: [NDKKind.Text, NDKKind.GroupReply], ...event.filter() },
        { kinds: [NDKKind.Text, NDKKind.GroupReply], "#e": [ event.id ] },
    ], { subId: 'item-view-replies' });

    onDestroy(() => {
        replies.unsubscribe();
    });
    
    /**
     * Only gets the root events of conversations, except on 30041 because those are not root events themselves
     */
    const onlyRootEvents = derived(replies, $replies => {
        if (event.kind === 30041) {
            return $replies;
        } else {
            return $replies.filter(isDirectReply(event))
        }
    });

    let zapEvent: NDKEvent | undefined;
    let zapInvoice: NDKZapInvoice | undefined;
    let zap: UnsubscribableStore<ZapInvoiceWithEvent[]>;

    getTopZapsByIndividualAmount(event, 1).then((zaps) => {
        zap = zaps;
    });

    onDestroy(() => { zap?.unsubscribe(); });

    $: if (zap && $zap) {
        zapEvent = $zap[0]?.event;
        zapInvoice = $zap[0];
    }

    function addComment() {
        const e = new NDKEvent();
        e.tag(event!, "root");
        openModal(NewPostModal, {
            title: "New Comment",
            tags: e.tags,
            placeholder: "Write a comment...",
            replyTo: event
        });
    }
</script>

{#if zapEvent && zapInvoice}
    <StylishContainer
        class="p-4"
        border={2}
        backgroundOpacity={0.6}
    >
        <div class="flex flex-row w-full justify-between">
            <AvatarWithName pubkey={zapInvoice?.zappee} />

            <div class="flex flex-row gap-2 items-center text-foreground font-semibold">
                <Lightning size={24} class="text-accent" weight="fill" />
                TOP ZAP
            </div>
        </div>
        
        <div class="mt-4">
            <EventContent
                ndk={$ndk}
                event={zapEvent}
            />
        </div>
    </StylishContainer>
{/if}

{#if $onlyRootEvents.length === 0}
    <BlankState
        cta="Write your thoughts"
        on:click={addComment}
    >
        <NoComments slot="illustration" class="w-full h-full" />

        No comments yet
    </BlankState>
{/if}
<StoreFeed
    feed={onlyRootEvents}
    eventProps={{
        compact: true,
        class: 'bg-foreground/20 p-4 my-2 rounded border border-white/10'
    }}
/>