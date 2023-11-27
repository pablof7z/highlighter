<script lang="ts">
    import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { ndk, Name, Avatar } from "@kind0/ui-common";
    import { userSuperFollows, userCreatorSubscriptionPlans } from "$stores/session";
	import { NDKEvent, type NDKFilter } from "@nostr-dev-kit/ndk";
	import FeedEvent from "$components/Feed/FeedEvent.svelte";
	import { onMount } from "svelte";

    let activeFilterCount: number | undefined = undefined;

    function getFilters() {
        const filters: NDKFilter[] = [];

        activeFilterCount = $userSuperFollows.size;

        for (const pubkey of $userSuperFollows) {
            const plan = $userCreatorSubscriptionPlans.get(pubkey) ?? "Free";
            filters.push({ "#h": [pubkey], "#f": [plan] });
        }

        return filters;
    }

    let events: NDKEventStore<NDKEvent> | undefined;

    $: if (activeFilterCount && $userSuperFollows.size !== activeFilterCount) {
        console.log(`change filters from ${activeFilterCount} to ${$userSuperFollows.size} filters`);
        events?.changeFilters(getFilters());
        events = $ndk.storeSubscribe(
            getFilters(),
            { groupable: false, subId: 'inbox' }
        )
    }

    onMount(() => {
        events = $ndk.storeSubscribe(
            getFilters(),
            { groupable: false, subId: 'inbox' }
        )
    });


    let mode = "all";
</script>

<div class="flex flex-row gap-8 mx-auto max-w-6xl">
    <div class="px-6 pt-4 pb-6 rounded-3xl border border-neutral-800 flex-col justify-start items-start gap-6 inline-flex w-[300px] shrink-0">
        <div class="self-stretch justify-start items-center gap-6 inline-flex">
            <div class="grow shrink basis-0 text-white text-2xl font-semibold font-['Inter Display']">Inbox</div>
            <div class="justify-start items-center flex">
                <div role="tablist" class="tabs tabs-boxed bg-transparent">
                    <button
                        role="tab"
                        class="tab"
                        class:tab-active={mode === 'all'}
                        on:click={() => mode = 'all'}
                    >All</button>
                    <button
                        role="tab"
                        class="tab"
                        class:tab-active={mode === 'paid'}
                        on:click={() => mode = 'paid'}
                    >Paid</button>
                </div>
            </div>
        </div>
        <div class="flex-col justify-center items-start gap-3 flex">
            <div class="flex-col justify-start items-start gap-3 flex">
                <div class="justify-start items-center gap-2 inline-flex">
                    <div class="w-11 h-11 p-2.5 bg-zinc-800 rounded-[100px] justify-center items-center flex">
                        <div class="w-6 h-6 relative flex-col justify-start items-start flex"></div>
                    </div>
                    <div class="text-right text-white text-[15px] font-medium">All Feeds</div>
                </div>
                {#each $userSuperFollows as pubkey}
                    <a href="?id={pubkey}" class="justify-start items-center gap-2 inline-flex">
                        <Avatar {pubkey} class="w-11 h-11 rounded-full" />
                        <Name {pubkey} class="text-right text-white text-opacity-60 text-[15px] font-medium" />
                    </a>
                {/each}
            </div>
        </div>
        <div class="w-[9px] h-7 bg-zinc-800 rounded-[28px]"></div>
    </div>
    <div class="flex-col justify-start items-start gap-8 flex w-full">
        {#if events && $events}
            {#each $events as event (event.id)}
                <FeedEvent {event} />
            {/each}
        {/if}
    </div>
</div>

<style lang="postcss">
    .tab-active {
        @apply !bg-white !text-black;
    }
</style>