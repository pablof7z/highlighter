<script lang="ts">
	import BoostModal from '$modals/BoostModal.svelte';
	import RepostIcon from "$icons/RepostIcon.svelte";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from "svelte-modals";

    export let event: NDKEvent;

    const reposts = $ndk.storeSubscribe(
        [
            { kinds: [6, 16], ...event.filter() },
            { kinds: [1], "#q": [ event.id, event.tagReference()[1] ] },
        ],
        {
            cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
            groupableDelay: 100,
            groupableDelayType: "at-least",
        }
    );

    onDestroy(() => {
        reposts.unref();
    });

    let repostedByUser = false;

    function findUserReaction(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    $: repostedByUser = !!$reposts.find(findUserReaction);

    function boost() {
        openModal(BoostModal, { event });
    }
</script>

<div class="tooltip" data-tip="Share">
    <button on:click|stopPropagation|preventDefault={boost}
        class="flex flex-row items-center gap-2 {repostedByUser ? 'text-white' : ''}"
    >
        {#if repostedByUser}
            <RepostIcon class="w-7 h-7 text-accent" />
        {:else}
            <RepostIcon class="w-7 h-7" weight="regular" />
        {/if}
    </button>
</div>