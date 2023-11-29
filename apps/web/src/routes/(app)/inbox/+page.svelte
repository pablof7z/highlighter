<script lang="ts">
	import SuperFollowList from './SuperFollowList.svelte';
    import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { ndk, Name, Avatar } from "@kind0/ui-common";
    import { userSuperFollows, userCreatorSubscriptionPlans } from "$stores/session";
	import { NDKEvent, type NDKFilter, type NostrEvent } from "@nostr-dev-kit/ndk";
	import FeedEvent from "$components/Feed/FeedEvent.svelte";
	import { onMount } from "svelte";
	import { fade, slide } from 'svelte/transition';

    let activeFilterCount: number | undefined = undefined;
    let activeView = $userSuperFollows;

    function getFilters() {
        const filters: NDKFilter[] = [];

        activeFilterCount = activeView.size;

        for (const pubkey of activeView) {
            const plan = $userCreatorSubscriptionPlans.get(pubkey) ?? "Free";
            filters.push({ "#h": [pubkey], "#f": [plan] });
        }

        return filters;
    }

    let events: NDKEventStore<NDKEvent> | undefined;

    $: if (activeFilterCount !== undefined && activeView.size !== activeFilterCount) {
        console.log(`change filters from ${activeFilterCount} to ${activeView.size} filters`);
        events?.changeFilters(getFilters());
        events = $ndk.storeSubscribe(
            getFilters(),
            { groupable: false, subId: 'inbox' }
        )
        events.startSubscription();
    }

    onMount(() => {
        const filters = getFilters();
        events = $ndk.storeSubscribe(
            filters,
            { groupable: false, subId: 'inbox', autoStart: false }
        )
        if (filters.length > 0) {
            events.startSubscription();
        }
    });
</script>

<div class="flex flex-row gap-8 mx-auto max-w-6xl">
    <div class="w-[300px] flex-none">
        <SuperFollowList bind:activeView class="fixed" />
    </div>

    <div class="flex-col justify-start items-start gap-8 flex w-full">
        {#if events && $events}
            {#each $events as event (event.id)}
                <div class="w-full" transition:slide>
                    <FeedEvent {event} />
                </div>
            {/each}
        {/if}
    </div>
</div>
