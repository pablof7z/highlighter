<script lang="ts">
	import ZapButton from "$components/buttons/ZapButton.svelte";
	import TopZap from "$components/Events/TopZap.svelte";
    import RecentZaps from "$components/Events/Zaps/RecentZaps.svelte";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let hasZaps: boolean | undefined = undefined;

    let topZapEvent: NDKEvent | undefined = undefined;
    let skipRecentZaps: NDKEventId[] = [];
    let recentZaps: NDKEvent[] = [];
    let showHelperText = true;

    $: skipRecentZaps = topZapEvent ? [topZapEvent.id] : [];

    $: showHelperText = !topZapEvent;

    $: hasZaps = recentZaps.length > 0;
</script>

<div class="flex flex-row gap-1 items-center {$$props.class??""} overflow-x-auto w-full flex-nowrap scrollbar-hide">
    <div class="flex-none">
        <TopZap {event} class="text-sm w-fit whitespace-nowrap" avatarSize="small" bind:zapEvent={topZapEvent} />
    </div>
    <!-- <div class="flex flex-row gap-2 items-center text-sm" class:hidden={!topZapEvent}>
        <CrownSimple class="w-6 h-6 text-accent" />
        <div class="text-foreground whitespace-nowrap">Top Zapper</div>
    </div> -->
<!-- </div> -->

<!-- <div class="flex flex-row gap-2 flex-nowrap items-center overflow-x-auto scrollbar-hide"> -->
    <ZapButton {event} class="text-xs" {showHelperText} />
    <!-- <div class="w-[1px] h-[20px] mx-2 border-l border-border" class:hidden={recentZaps.length < 2}></div> -->
    <RecentZaps {event} class="text-xs flex-none" avatarSize="tiny" skipEventIds={skipRecentZaps} bind:zapEvents={recentZaps} />
</div>