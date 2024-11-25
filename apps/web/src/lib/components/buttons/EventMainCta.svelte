<script lang="ts">
	import SubscribeModal from '$modals/SubscribeModal/index.svelte';
	import { ndk } from "$stores/ndk";
	import NDK, { NDKEvent, NDKFilter, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import AddToInbox from "./AddToInbox.svelte";
	import { Button } from "$components/ui/button";
	import { Box } from "lucide-svelte";
	import { openModal } from "$utils/modal";

    export let event: NDKEvent;
    
    const hTags = event.getMatchingTags("h");
    const groupIds = hTags.map(hTag => hTag[1]).filter(u => !!u);
    const relays = hTags.map(hTag => hTag[2]).filter(u => !!u);
    const relaySet = relays.length > 0 ? NDKRelaySet.fromRelayUrls(relays, $ndk) : undefined;

    const filters: NDKFilter[] = [];

    if (groupIds.length > 0) {
        filters.push({ kinds: [NDKKind.TierList], "#h": groupIds});
    }

    filters.push({ kinds: [NDKKind.TierList], authors: [event.pubkey]});

    const tiers = $ndk.storeSubscribe(filters, { relaySet, closeOnEose: true });

    function subscribe() {
        openModal(SubscribeModal, { event })
    }
</script>

{#if $tiers.length > 0}
    <Button variant="accent" class="flex flex-row gap-2.5 items-center p-3" on:click={subscribe}>
        <Box size={20} />
        Subscribe
    </Button>
{:else}
    <AddToInbox {...$$props} />
{/if}