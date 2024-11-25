<script lang="ts">
	import SubscribeModal from '$modals/SubscribeModal/index.svelte';
	import { ndk } from "$stores/ndk";
	import NDK, { NDKEvent, NDKFilter, NDKKind, NDKRelaySet } from "@nostr-dev-kit/ndk";
	import AddToInbox from "./AddToInbox.svelte";
	import { Button } from "$components/ui/button";
	import { Box } from "lucide-svelte";
	import { openModal } from "$utils/modal";
    import * as Groups from "$components/Groups";
	import { Readable } from 'svelte/store';

    export let group: Readable<Groups.GroupData>;
    
    const hasTiers = $group.tiers && $group.tiers.length > 0;

    function subscribe() {
        openModal(SubscribeModal, { group })
    }
</script>

{#if hasTiers}
    <Button variant="accent" class="flex flex-row gap-2.5 items-center p-3" on:click={subscribe}>
        <Box size={20} />
        Subscribe
    </Button>
{:else}
    <AddToInbox {...$$props} />
{/if}