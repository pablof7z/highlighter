<script lang="ts">
	import BoostModal from '$modals/ShareModal.svelte';
	import { ndk } from "$stores/ndk.js";
	import { type NDKEvent, NDKKind, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, onDestroy } from "svelte";
	import { openModal } from '$utils/modal';
	import { Quotes, Repeat, ShareNetwork, Timer } from 'phosphor-svelte';
	import ButtonWithCount from './ButtonWithCount.svelte';
	import currentUser from '$stores/currentUser';
	import Scheduler from '$modals/Scheduler.svelte';
	import QuoteModal from '$modals/QuoteModal.svelte';
    import * as HoverCard from "$lib/components/ui/hover-card/index.js";
	import { Button } from '$components/ui/button';

    export let event: NDKEvent;

    const reposts = $ndk.storeSubscribe(
        [
            { kinds: [6, 16], ...event.filter() },
            { kinds: [1], "#q": [ event.id, event.tagReference()[1] ] },
        ],
        {
            groupableDelay: 1500,
            groupableDelayType: "at-least",
        }
    );

    onDestroy(() => {
        reposts.unref();
    });

    const dispatch = createEventDispatcher();

    let repostedByUser = false;

    $: if ($currentUser && !repostedByUser) repostedByUser = !!$reposts.find(e => e.pubkey === $currentUser!.pubkey)

    function share() {
        openModal(BoostModal, {event, onPublish: (event: NDKEvent) => dispatch('publish', event)});
    }

    function boost() {
        openModal(QuoteModal, {event, onPublish: (event: NDKEvent) => dispatch('publish', event)});
    }

    async function repost() {
        await event.repost();
        repostedByUser = !repostedByUser;
        const focusedElement = document.activeElement as HTMLElement;
        focusedElement?.blur();
    }

    function scheduleBoost() {
        openModal(Scheduler, { event })
    }

    let container: HTMLDivElement;
</script>

{#if event.kind === NDKKind.Text || event.kind === NDKKind.Highlight}
<HoverCard.Root
    closeOnEscape
    openDelay={0}
>
    <HoverCard.Trigger>
        <ButtonWithCount
            class="rounded-full p-2 flex hover:bg-green-400/20"
            count={$reposts.length}
            active={repostedByUser}
        >
            {#if repostedByUser}
                <Repeat class="sm:w-5 w-3.5 sm:h-5 h-3.5 text-[var(--boost-button)]/30 group-hover:text-[var(--boost-button)]" weight="fill" />
            {:else}
                <Repeat class="sm:w-5 w-3.5 sm:h-5 h-3.5 text-[var(--boost-button)]/30 group-hover:text-[var(--boost-button)]" weight="regular" />
            {/if}

        </ButtonWithCount>
    </HoverCard.Trigger>

    <HoverCard.Content class="w-auto flex flex-col gap-2">
        <ul class="flex flex-row gap-2">
            <Button variant="secondary" on:click={repost} class="flex flex-col items-center gap-2 w-24 h-24 text-secondary-content">
                <Repeat class="w-10 h-10" />
                <span class="">Repost</span>
            </Button>
            <Button variant="secondary" on:click={boost} class="flex flex-col items-center gap-2 w-24 h-24 text-secondary-content">
                <Quotes class="w-10 h-10" />
            <span class="">Quote</span>
            </Button>
        </ul>
        <Button variant="secondary" class="!flex-row group !h-12 !w-full text-secondary-content" on:click={scheduleBoost}>
            <Timer class="w-6 h-6" />
            <span class="whitespace-nowrap">Scheduled Repost</span>
        </Button>
    </HoverCard.Content>
</HoverCard.Root>
{:else}
    <button on:click|stopPropagation|preventDefault={share}
        class="flex flex-row items-center gap-2 {repostedByUser ? 'text-foreground' : ''}"
    >
        {#if repostedByUser}
            <ShareNetwork class="sm:w-5 w-6 sm:h-5 h-6 text-accent" />
        {:else}
            <ShareNetwork class="sm:w-5 w-6 sm:h-5 h-6" weight="regular" />
        {/if}
    </button>
{/if}

<style lang="postcss">
    ul button {
        @apply bg-background border border-border hover:border-white/50 hover:bg-foreground/10 rounded p-4 flex flex-col items-center gap-2 w-24 h-24;
    }

    ul button span {
        @apply text-opacity-80 group-hover:text-opacity-100 font-medium text-sm;
    }
</style>