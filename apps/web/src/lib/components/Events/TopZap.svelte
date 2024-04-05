<script lang="ts">
	import { UnsubscribableStore, ZapInvoiceWithEvent, getTopZapsByIndividualAmount } from "$utils/zaps";
	import { nicelyFormattedMilliSatNumber } from "@kind0/ui-common";
	import { NDKEvent, NDKZapInvoice } from "@nostr-dev-kit/ndk";
    import {Avatar} from "@kind0/ui-common";
	import { onDestroy } from "svelte";
	import ZapPill from "./Zaps/ZapPill.svelte";

    export let event: NDKEvent;
    export let avatarSize: "tiny" | "small" | "medium" | "large" = "tiny";
    export let zapEvent: NDKEvent | undefined = undefined;

    let zap: UnsubscribableStore<ZapInvoiceWithEvent[]>;

    getTopZapsByIndividualAmount(event, 1).then((zaps) => {
        zap = zaps;
    });

    onDestroy(() => { zap?.unsubscribe(); });

    $: if (zap && $zap) zapEvent = $zap[0]?.event;
</script>

{#if zap && $zap.length > 0}
    {#key $zap[0].zappee}
        <ZapPill zap={$zap[0]} avatarSize={avatarSize} comment="show" class={$$props.class} />
    {/key}
{/if}