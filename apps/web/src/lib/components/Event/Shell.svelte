<script lang="ts">
    import Swipe from '$components/Swipe.svelte';
	import { toggleBookmarkedEvent } from '$lib/events/bookmark';
	import NewPostModal from '$modals/NewPostModal.svelte';
	import QuoteModal from '$modals/QuoteModal.svelte';
	import Scheduler from '$modals/Scheduler.svelte';
	import ZapModal from '$modals/ZapModal.svelte';
	import { userGenericCuration } from '$stores/session';
	import { openModal } from '$utils/modal';
	import { NDKEvent } from '@nostr-dev-kit/ndk';
	import { Quotes, BookmarkSimple, Lightning, Repeat, Timer, ChatCircle } from 'phosphor-svelte';
	import { toast } from 'svelte-sonner';

    export let event: NDKEvent;
    export let disableSwipe: boolean | undefined = undefined;
    
    let rightOptions: any;

    let showQuoteOptions = false;
    

    $: if (!showQuoteOptions) {
        rightOptions = [
            { id: "Quote", icon: Quotes, class: "bg-green-500/10 !text-green-500", fn: () => { showQuoteOptions = true; return true; } },
            { id: 'Bookmark', icon: BookmarkSimple, class: "bg-red-500/10 !text-red-500", fn: bookmark },
            { id: 'Zap!', icon: Lightning, class: "bg-yellow-500/10 !text-yellow-500", iconProps: { weight: 'fill' }, fn: () => openModal(ZapModal, { event })}
        ]
    } else {
        rightOptions = [
            { name: "Repost", icon: Repeat, class: "bg-foreground/30", fn: repost },
            { name: "Quote", icon: Quotes, class: "bg-foreground/60", fn: () => openModal(QuoteModal, { event }) },
            { name: "Schedule", icon: Timer, class: "bg-foreground/90", fn: () => {openModal(Scheduler, {event})} }
        ];
    }

    function onSwipeToReply() {
        openModal(NewPostModal, {
            replyTo: event,
        });
    }

    async function repost() {
        const e = await event.repost(false);
        toast.success("Reposted");
        e.publish();
    }

    async function bookmark() {
        try {
            toast.success("Bookmark saved");
            $userGenericCuration = await toggleBookmarkedEvent(event, $userGenericCuration);
        } catch (e: any) {
            toast.error(e.relayErrors ?? e.message)
        }
    }
</script>

{#if disableSwipe}
    <slot />
{:else}
    <Swipe
        leftOptions={[
            { id: 'Reply', icon: ChatCircle, class: "!bg-accent/10 text-accent", fn: onSwipeToReply },
        ]}
        on:close={() => showQuoteOptions = false}
        {rightOptions}
    >
        <slot />
    </Swipe>
{/if}