<script lang="ts">
	import TopZap from "$components/Events/TopZap.svelte";
	import ZapButton from "$components/buttons/ZapButton.svelte";
    import RecentZaps from "$components/Events/Zaps/RecentZaps.svelte";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import { CrownSimple } from "phosphor-svelte";

    export let event: NDKEvent;

    let topZapEvent: NDKEvent | undefined;
    let skipRecentZaps: NDKEventId[] = [];
    let recentZaps: NDKEvent[] = [];
    let showHelperText = true;

    $: skipRecentZaps = topZapEvent ? [topZapEvent.id] : [];

    $: showHelperText = !topZapEvent;
</script>

<div class="flex flex-row gap-1 items-center {$$props.class??""}">
    <TopZap {event} class="text-sm w-fit whitespace-nowrap" avatarSize="small" bind:zapEvent={topZapEvent} />
    <div class="flex flex-row gap-2 items-center text-sm" class:hidden={!topZapEvent}>
        <CrownSimple class="w-6 h-6 text-accent2" />
        <div class="text-white whitespace-nowrap">Top Zapper</div>
    </div>
</div>

<div class="flex flex-row gap-2 flex-nowrap items-center overflow-x-auto scrollbar-hide">
    <ZapButton {event} class="text-xs" {showHelperText} />
    <div class="w-[1px] h-[20px] mx-2 border-l border-white/50" class:hidden={recentZaps.length < 2}></div>
    <RecentZaps {event} class="text-xs flex-none" avatarSize="tiny" skipEventIds={skipRecentZaps} bind:zapEvents={recentZaps} />
</div>