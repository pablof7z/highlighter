<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
	import { userFollows } from "$stores/session";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy } from "svelte";
	import { writable } from "svelte/store";

    export let event: NDKEvent;

    const debug = createDebug("highlighter:highlights");

    const typeFilter = writable<App.FilterType[]>(["all"]);
    let selectedCategory: string;
    let open = false;

    $: selectedCategory = $page.params.category || "All";

    const authors = Array.from($userFollows);

    const filters: NDKFilter[] = [ { kinds: [NDKKind.Highlight], ...event.filter() } ];

    // If we have authors to filter by, add them to the filter
    if (authors.length > 0) { filters[0].authors = authors; }

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

<div class="flex flex-row gap-8 mx-auto mt-8 w-full">
    <div class="
        max-sm:px-[var(--mobile-body-px)] max-sm:pt-[var(--mobile-nav-bar)]
        flex-col justify-start items-start flex w-full sm:max-w-[680px]
        gap-6
    ">
        {#each $events as event}
            <ClipItem {event} class="bg-base-100/60" />
        {/each}
    </div>
</div>