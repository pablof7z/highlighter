<script lang="ts">
	import { page } from "$app/stores";
	import ClipItem from "$components/Clips/ClipItem.svelte";
	import { userFollows } from "$stores/session";
	import { ndk } from "@kind0/ui-common";
	import { NDKKind, type NDKFilter, NDKSubscriptionCacheUsage, NDKEvent } from "@nostr-dev-kit/ndk";
    import createDebug from "debug";
	import { onDestroy } from "svelte";
	import { writable } from "svelte/store";

    export let filter: NDKFilter;

    const debug = createDebug("highlighter:highlights");

    let selectedCategory: string;

    $: selectedCategory = $page.params.category || "All";

    const filters: NDKFilter[] = [ { kinds: [NDKKind.Highlight], ...filter } ];

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
        max-sm:px-[var(--mobile-body-px)]
        flex-col justify-start items-start flex w-full
        gap-6
    ">
        {#each $events as event}
            <ClipItem {event} class="bg-base-100/60" />
        {/each}
    </div>
</div>