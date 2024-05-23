<script lang="ts">
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { mainContentKinds } from '$utils/event';
    import { page } from '$app/stores';
    import type { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { Avatar, ndk } from "@kind0/ui-common";
    import { userFollows } from "$stores/session";
    import { type NDKEvent, type NDKFilter, NDKKind, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
    import { pageHeader, pageSidebar } from "$stores/layout";
	import { mode } from '$stores/inbox-view';
	import { inboxItems } from '$stores/inbox';
	import ComplexHeaderWithBanner from '$components/PageElements/ComplexHeaderWithBanner.svelte';
	import currentUser from '$stores/currentUser';

    let activeFilterCount: number | undefined = undefined;
    let activeView = $userFollows;

    let selectedNip05: string | undefined = undefined;
    let selectedPubkey: string | undefined = undefined;

    $: {
        selectedNip05 = $page.url.searchParams.get("id") || undefined;
        if (selectedNip05) {
            if (selectedNip05.match(/@/)) {
                $ndk.getUserFromNip05(selectedNip05).then(user => {
                    selectedPubkey = user?.pubkey;
                })
            } else {
                selectedPubkey = selectedNip05;
            }
        } else {
            selectedPubkey = undefined;
        }
    }

    function getFilters() {
        const filters: NDKFilter[] = [];

        activeFilterCount = activeView.size;

        for (const pubkey of activeView) {
            // const plan = $userCreatorSubscriptionPlans.get(pubkey) ?? "Free";
            // filters.push({ "#h": [pubkey], "#f": [plan] });
        }

        if ($mode === "all") {
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

    onDestroy(() => {
        $pageSidebar = null;
    })

    $pageHeader = {
        title: "Inbox",
        searchBar: true
    }

    const kinds = [
        NDKKind.Highlight,
        ...mainContentKinds
    ]

    const feed = $ndk.storeSubscribe([
        { kinds: kinds, authors: Array.from($inboxItems)}
    ], {
        repostsFilters: [
            { kinds: [6, 16], "#k": kinds.map(a => a.toString()), authors: Array.from($inboxItems), limit: 50 }
        ],
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    })
</script>

<svelte:head>
    <title>Inbox</title>
</svelte:head>

<ComplexHeaderWithBanner
    user={$currentUser}
    image={`https://picsum.photos/800/600?random=Inbox}`}
>
    <span slot="title">Inbox</span>
    <span slot="subtitle">
        A quiet place for the most important content.
    </span>
    <div slot="options" class="flex flex-row gap-2 flex-nowrap w-full scrollbar-hide overflow-x-auto p-2" let:collapsed>
        {#each $inboxItems as item}
            {#if item}
                <Avatar pubkey={item} class="
                    transition-all duration-300
                    {collapsed ? "w-8 h-8" : "w-12 h-12"}
                " />
            {/if}
        {/each}
    </div>

    <StoreFeed {feed} />
</ComplexHeaderWithBanner>