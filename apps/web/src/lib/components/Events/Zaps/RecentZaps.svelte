<script lang="ts">
	import { UnsubscribableStore, ZapInvoiceWithEvent, getRecentZaps, getTopZapsByIndividualAmount } from "$utils/zaps";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import ZapPill from "./ZapPill.svelte";

    export let event: NDKEvent;
    export let avatarSize: "tiny" | "small" | "medium" | "large" = "tiny";
    export let count = 10;
    export let skipEventIds: NDKEventId[] = [];
    export let zapEvents: NDKEvent[] = [];

    let zaps: UnsubscribableStore<ZapInvoiceWithEvent[]>;

    getRecentZaps(event, count).then((z) => {
        zaps = z;
    });

    onDestroy(() => { zaps?.unsubscribe(); });

    $: zapEvents = $zaps ? $zaps?.map(z => z.event) : [];
</script>

{#if zaps && $zaps.length > 0}
    {#each $zaps as zap, i (zap.event.id)}
        {#if !skipEventIds.includes(zap.event.id)}
            <ZapPill {zap} {avatarSize} class={$$props.class} />
        {/if}
    {/each}
{/if}