<script lang="ts">
	import BoostModal from '$modals/BoostModal.svelte';
	import RepostIcon from "$icons/RepostIcon.svelte";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { openModal } from "svelte-modals";

    export let event: NDKEvent;

    const reactions = $ndk.storeSubscribe(
        { kinds: [7], ...event.filter() },
        { cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY}
    );

    onDestroy(() => {
        reactions.unref();
    });

    let reactedByUser = false;

    function findUserReaction(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    $: reactedByUser = !!$reactions.find(findUserReaction);

    function boost() {
        openModal(BoostModal, { event });
    }
</script>

<button class="w-7 h-7 relative" on:click|stopPropagation|preventDefault={boost}>
    {#if reactedByUser}
        <RepostIcon class="w-7 h-7 text-accent" />
    {:else}
        <RepostIcon class="w-7 h-7 text-white" weight="regular" />
    {/if}
</button>