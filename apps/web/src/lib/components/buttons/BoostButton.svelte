<script lang="ts">
	import BoostModal from '$modals/ShareModal.svelte';
	import { ndk } from "@kind0/ui-common";
	import { type NDKEvent, NDKKind, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, onDestroy } from "svelte";
	import { openModal } from "svelte-modals";
	import { Quotes, Repeat, ShareNetwork, Timer } from 'phosphor-svelte';
	import ButtonWithCount from './ButtonWithCount.svelte';
	import currentUser from '$stores/currentUser';
	import Scheduler from '$modals/Scheduler.svelte';
	import QuoteModal from '$modals/QuoteModal.svelte';

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
    <div class="dropdown dropdown-hover lg:dropdown-end" bind:this={container}>
        <div tabindex="0" role="button">
            <ButtonWithCount
                count={$reposts.length}
                active={repostedByUser}
            >
                {#if repostedByUser}
                    <Repeat class="sm:w-5 w-3.5 sm:h-5 h-3.5 text-accent2" weight="fill" />
                {:else}
                    <Repeat class="sm:w-5 w-3.5 sm:h-5 h-3.5" weight="regular" />
                {/if}

            </ButtonWithCount>
        </div>

        <ul tabindex="0" class="dropdown-content z-[50] p-2 bg-base-300 rounded-box w-fit flex flex-col shadow-2xl gap-2">
            <div class="flex flex-row gap-2">
                <li><button on:click={repost} class="group">
                    <Repeat class="w-10 h-10" />
                    <span class="text-base-100-content/80 group-hover:text-base-100-content">Repost</span>
                </button></li>
                <li><button on:click={boost} class="group">
                    <Quotes class="w-10 h-10" />
                <span class="text-base-100-content/80 group-hover:text-base-100-content">Quote</span>
                </button></li>
            </div>
            <li><button class="!flex-row group !h-12 !w-full" on:click={scheduleBoost}>
                <Timer class="w-6 h-6" />
                <span class="text-base-100-content/80 group-hover:text-base-100-content whitespace-nowrap">Scheduled Repost</span>
            </button></li>

        </ul>
    </div>
{:else}
    <button on:click|stopPropagation|preventDefault={share}
        class="flex flex-row items-center gap-2 {repostedByUser ? 'text-base-100-content' : ''}"
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
        @apply bg-base-100 border border-base-100 hover:border-white/50 hover:bg-base-200 rounded-box p-4 flex flex-col items-center gap-2 w-24 h-24;
    }

    ul button span {
        @apply text-base-100-content text-opacity-80 group-hover:text-opacity-100 font-medium text-sm;
    }
</style>