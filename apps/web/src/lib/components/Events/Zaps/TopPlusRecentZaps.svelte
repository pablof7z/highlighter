<script lang="ts">
	import { Readable } from 'svelte/store';
	import { UnsubscribableStore, ZapInvoiceWithEvent, topPlusRecentZaps } from "$utils/zaps";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import ZapPill from "./ZapPill.svelte";
	import { Crown } from "phosphor-svelte";
	import throttleStore from '$utils/stores/throttle';

    export let event: NDKEvent;
    export let avatarSize: "tiny" | "small" | "medium" | "large" = "tiny";
    export let count = 10;
    export let skipEventIds: NDKEventId[] = [];
    export let zapEvents: NDKEvent[] = [];
    export let isNoop: boolean | undefined = false;

    let zaps: UnsubscribableStore<ZapInvoiceWithEvent[]>;
    let throttleZaps: Readable<ZapInvoiceWithEvent[]>;

    topPlusRecentZaps(event, count).then((z) => {
        zaps = z;
        throttleZaps = throttleStore(zaps, 200);
    });

    onDestroy(() => { zaps?.unsubscribe(); });

    $: zapEvents = $throttleZaps ? $throttleZaps?.map(z => z.event) : [];
    $: isNoop = !(throttleZaps && $throttleZaps.length > 0);
</script>

{#if throttleZaps && $throttleZaps.length > 0}
    <div class="flex flex-row items-start gap-2 justify-between w-full">
        <div class="flex flex-row items-center gap-2">
            <ZapPill
                zap={$throttleZaps[0]}
                avatarSize={avatarSize}
                comment="show"
                class="
                    border-2 border-yellow-400/50
                    bg-yellow-400/20
                    {$$props.class}
                "
                icon={Crown}
            />
        </div>
        <div class="flex flex-row">
            {#each $throttleZaps.slice(1, -1) as zap, i (zap.event.id)}
                {#if !skipEventIds.includes(zap.event.id)}
                    <ZapPill {zap} {avatarSize} class={$$props.class} />
                {/if}
            {/each}
        </div>
    </div>
{/if}