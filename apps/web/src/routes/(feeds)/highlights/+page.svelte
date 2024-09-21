<script lang="ts">
	import { page } from "$app/stores";
	import { userFollows } from "$stores/session";
	import { ndk } from "$stores/ndk.js";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent, NDKHighlight, NDKRelaySet, NDKRelay, NDKTag, NDKArticle, NDKVideo, Hexpubkey } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
    import { layout, searching } from "$stores/layout";
	import { getNip50RelaySet } from "$utils/ndk";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
	import { Input } from "$components/ui/input";
	import { Button } from "$components/ui/button";
	import { ArrowRight, Pen } from "phosphor-svelte";
	import { goto } from "$app/navigation";
	import { derived, writable } from "svelte/store";
	import HighlightedItems from "$components/HorizontalFeed/HighlightedItems.svelte";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";

    $layout.title = "Highlights";
    $layout.navigation = false;
    $layout.fullWidth = true;
    $layout.back = undefined;

    onDestroy(() => {
        $layout.fullWidth = undefined;
    });
    
    let selectedCategory: string;
    let events: NDKEventStore<NDKEvent> | undefined = undefined;

    $: selectedCategory = $page.params.category || "All";

    function getFilters(query?: string): NDKFilter[] {
        const filters: NDKFilter[] = [
            { kinds: [NDKKind.Highlight], limit: 1 },
            { kinds: [NDKKind.Text], "#k": [NDKKind.Highlight.toString()], limit: 100 }
        ];

        const userHasEnoughFollows = $userFollows?.size >= 100;

        // if (userHasEnoughFollows)
        //     filters[0].authors = Array.from($userFollows);

        return filters;
    }

    const highlights = $ndk.storeSubscribe([
        {kinds: [NDKKind.Highlight], limit: 500},
        {kinds: [NDKKind.Highlight], authors: Array.from($userFollows), limit: 150},
    ], {
        relaySet: NDKRelaySet.fromRelayUrls(['wss://relay.primal.net'], $ndk),
        closeOnEose: true
    }, NDKHighlight);

    const highlightersToFeature = derived(highlights, $highlights => {
        const highlighters = new Map<Hexpubkey, Set<string>>();
        
        for (const highlight of $highlights) {
            const highlighter = highlight.pubkey;
            const current = highlighters.get(highlighter) ?? new Set();
            const tag = highlight.getArticleTag();
            if (!tag) continue;
            current.add(tag[1]);

            highlighters.set(highlighter, current);
        }

        // sort by count and return array
        return Array.from(highlighters.entries()).sort((a, b) => b[1].size - a[1].size).map(([pubkey]) => pubkey as Hexpubkey);
    });

    const followHighlights = derived(highlights, $highlights => {
        return $highlights.filter(highlight => $userFollows.has(highlight.pubkey));
    });

    function getRelaySetForSubscription(filters: NDKFilter[]) {
        if (filters[0].search) {
            return getNip50RelaySet();
        }

        return undefined;
    }

    function startSubscription(query?: string) {
        events?.unsubscribe();
        $searching = true;
        const filters = getFilters(query);
        events = $ndk.storeSubscribe(filters, {
            groupable: false,
            subId: "highlights",
            autoStart: true,
            cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY,
            relaySet: getRelaySetForSubscription(filters),
        });
        events.onEose(() => { $searching = false; });
    }

    startSubscription();

    onDestroy(() => {
        events?.unsubscribe();
    });

    let url: string;

    function highlight() {
        goto('/load?url='+encodeURIComponent(url))
    }
</script>

<HighlightedItems {highlights} />

<!-- <div class="grid grid-cols-3 gap-6">
    <Card.Root>
        <Card.Header
            class="flex flex-row items-center justify-between space-y-0 pb-2"
        >
            <Card.Title class="text-sm font-medium">

            </Card.Title>
            <Pen class="text-muted-foreground h-4 w-4" />
        </Card.Header>
        <Card.Content>
        </Card.Content>
    </Card.Root>
</div> -->

<div class="lg:max-w-[calc(var(--content-focused-width)+270px)] mx-auto lg:px-0 max-sm:w-screen">

    <div class="my-4 relative flex flex-row items-center justify-stretch rounded">
        <Input
            bind:value={url}
            class="text-xl p-6 h-auto placeholder:text-opacity-50"
            placeholder="Enter URL or search for a highlight"
            on:submit={highlight}
        />
    
        <Button variant="secondary" class="absolute right-4 h-14 w-14 rounded" on:click={highlight}>
            <ArrowRight size={24} />
        </Button>
    </div>

    <div class="flex flex-row items-start gap-6 w-full">
        <StoreGrid
            gridSetup="grid-cols-1"
            feed={events}
            eventProps={{ compact: true }}
            renderLimit={1}
        />

        <div class="hidden md:flex flex-col w-[260px] h-full gap-4">
            {#each $highlightersToFeature.slice(0, 10) as pubkey}
                <AvatarWithName {pubkey} avatarSize="small" />
            {/each}
        </div>


    </div>
</div>
<!-- 
{#if $events}
    {#each $events as event (event.id)}
        {#if event.kind === NDKKind.Highlight}
            <Highlight highlight={NDKHighlight.from(event)} />
        {:else}
            <ClipItem {event} />
        {/if}
    {/each}
{/if} -->