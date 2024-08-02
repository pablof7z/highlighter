<script lang="ts">
    import Swipe from '$components/Swipe.svelte';
	import { toggleBookmarkedEvent } from '$lib/events/bookmark';
	import NewPostModal from '$modals/NewPostModal.svelte';
	import QuoteModal from '$modals/QuoteModal.svelte';
	import Scheduler from '$modals/Scheduler.svelte';
	import ZapModal from '$modals/ZapModal.svelte';
	import { userGenericCuration } from '$stores/session';
	import { newToasterMessage } from '$stores/toaster';
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
            { label: "Quote", icon: Quotes, class: "bg-white/10 !text-green-500", cb: () => { showQuoteOptions = true; return true; } },
            { label: 'Bookmark', icon: BookmarkSimple, class: "bg-white/20 !text-red-500", cb: bookmark },
            { label: 'Zap!', icon: Lightning, class: "bg-white/30 !text-yellow-500", cb: () => openModal(ZapModal, { event })}
        ]
    } else {
        rightOptions = [
            { label: "Repost", icon: Repeat, class: "bg-success/10", cb: repost },
            { label: "Quote", icon: Quotes, class: "bg-success/20", cb: () => openModal(QuoteModal, { event }) },
            { label: "Schedule", icon: Timer, class: "bg-success/30", cb: () => {openModal(Scheduler, {event})} }
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
            newToasterMessage(e.relayErrors ?? e.message, "error")
        }
    }
</script>

{#if disableSwipe}
    <slot />
{:else}
    <Swipe
        leftOptions={[
            { label: 'Reply', icon: ChatCircle, class: "bg-accent", cb: onSwipeToReply },
        ]}
        on:close={() => showQuoteOptions = false}
        {rightOptions}
    >
        <slot />
    </Swipe>
{/if}