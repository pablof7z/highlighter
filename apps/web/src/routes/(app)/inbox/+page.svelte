<script lang="ts">
	import SuperFollowList from './SuperFollowList.svelte';
    import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { ndk, Name, Avatar, user } from "@kind0/ui-common";
    import { userSuperFollows, userCreatorSubscriptionPlans, userFollows, debugPageFilter } from "$stores/session";
    import { NDKRelaySet, type NDKEvent, type NDKFilter, NDKSubscriptionCacheUsage, NDKKind } from "@nostr-dev-kit/ndk";
	import FeedEvent from "$components/Feed/FeedEvent.svelte";
	import { onMount } from "svelte";
	import { slide } from 'svelte/transition';
	import { Tray } from 'phosphor-svelte';
	import PageSidebar from '$components/PageSidebar.svelte';

    let activeFilterCount: number | undefined = undefined;
    let activeView = $userSuperFollows;
    let mode: "all" | "paid"  = 'paid';

    function getFilters() {
        const filters: NDKFilter[] = [];

        activeFilterCount = activeView.size;

        for (const pubkey of activeView) {
            const plan = $userCreatorSubscriptionPlans.get(pubkey) ?? "Free";
            filters.push({ "#h": [pubkey], "#f": [plan] });
        }

        if (mode === "all") {
            filters.push({
                authors: Array.from($userFollows),
                kinds: [
                    NDKKind.Article,
                    NDKKind.HorizontalVideo,
                ],
                limit: 50
            })
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

    onMount(async () => {
        const filters = getFilters();
        events = $ndk.storeSubscribe(
            filters,
            { groupable: false, subId: 'inbox', autoStart: false }
        )
        if (filters.length > 0) {
            events.startSubscription();
        }
    });

    let open = false;
</script>

<svelte:head>
    <title>Inbox</title>
</svelte:head>

<div class="flex flex-row gap-8 mx-auto">
    <PageSidebar title="Inbox" bind:open>
        <div slot="headerRight" class="justify-start items-center flex">
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

        <SuperFollowList bind:activeView bind:mode bind:open />
    </PageSidebar>

    <div class="
        max-sm:px-[var(--mobile-body-px)] max-sm:pt-[var(--mobile-nav-bar)]
        flex-col justify-start items-start flex w-full sm:max-w-[680px]
    ">
        {#if $userSuperFollows.size === 0}
            <div class="w-full bg-base-200 rounded-xl min-h-[50vh] h-full flex flex-col items-center justify-center gap-6">
                <Tray size="64" class="text-base-300" />
                <div class="text-xl opacity-60">
                    You are not following anyone yet
                </div>

                <a href="/explore" class="text-xl">
                    Explore Highlighter creators
                </a>
            </div>
        {:else if $events?.length === 0}
        <div class="w-full bg-base-200 rounded-xl min-h-[50vh] h-full flex flex-col items-center justify-center gap-6">
            <Tray size="64" class="text-base-300" />
            <div class="text-xl opacity-60">
                No posts to show
            </div>

            <a href="/explore" class="text-xl">
                Explore Highlighter creators
            </a>
        </div>
        {:else}
            {#if events && $events}
                {#each $events as event (event.id)}
                    <div class="w-full item" transition:slide>
                        <FeedEvent {event} />
                    </div>
                {/each}
            {/if}
        {/if}
    </div>
</div>

<style lang="postcss">
    .item:not(:first-child) {
        margin-top: 1rem;
    }

    .item:not(:last-child) {
        margin-bottom: 1rem;
    }

    .tab-active {
        @apply !bg-white !text-black;
    }

    a span.name {
        @apply text-opacity-60;
    }

    a.active span.name {
        @apply text-opacity-100;
    }
</style>