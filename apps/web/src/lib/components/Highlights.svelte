<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy } from "svelte";
	import Highlight from "./Highlight.svelte";
	import HighlightNote from "./HighlightNote.svelte";

    export let filter: NDKFilter | undefined = undefined;

    const debug = createDebug("highlighter:highlights");

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    export let filters: NDKFilter[] | undefined = undefined;

    if (!filters) filters = [ { kinds: [NDKKind.Highlight], ...filter } ];

    const events = $ndk.storeSubscribe(filters, {
        groupable: false,
        subId: "highlights",
        autoStart: true,
        cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY
    });

    onDestroy(() => {
        events?.unsubscribe();
    });
</script>

<div class="flex flex-row gap-8 mx-auto w-full">
    <div class="
        max-sm:px-[var(--mobile-body-px)]
        flex-col justify-start items-start flex w-full
        gap-6
    ">
        {#each $events as event}
            {#if event.kind === NDKKind.Highlight}
                <Highlight highlight={NDKHighlight.from(event)} class="bg-base-100/60" />
            {:else if event.kind === NDKKind.Text}
                <HighlightNote note={event} class="bg-base-100/60" />
            {:else}
                <ClipItem {event} class="bg-base-100/60" />
            {/if}
        {/each}
    </div>
</div>