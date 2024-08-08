<script lang="ts">
	import { UnsubscribableStore, ZapInvoiceWithEvent, getRecentZaps, getTopZapsByIndividualAmount } from "$utils/zaps";
	import { Hexpubkey, NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import ZapPill from "./ZapPill.svelte";
	import { derived, Readable } from "svelte/store";
	import AvatarsPill from "$components/Avatars/AvatarsPill.svelte";

    export let event: NDKEvent;
    export let avatarSize: "tiny" | "small" | "medium" | "large" = "tiny";
    export let count = 10;
    export let skipEventIds: NDKEventId[] = [];
    export let zapEvents: NDKEvent[] = [];

    let zaps: UnsubscribableStore<ZapInvoiceWithEvent[]>;
    let pubkeys: Readable<Hexpubkey[]>;

    getRecentZaps(event, count).then((z) => {
        zaps = z;

        pubkeys = derived(zaps, $zaps => {
            const p = new Set<Hexpubkey>();
            for (const zap of $zaps) {
                if (!skipEventIds.includes(zap.event.id)) {
                    p.add(zap.event.pubkey);
                }
            }

            return Array.from(p);
        })
    });

    onDestroy(() => { zaps?.unsubscribe(); });

    $: zapEvents = $zaps ? $zaps?.map(z => z.event) : [];
</script>

{#if pubkeys && $pubkeys.length}
    <AvatarsPill pubkeys={$pubkeys} size={avatarSize} />
{/if}
