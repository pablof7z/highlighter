<script lang="ts">
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { Avatar } from "@kind0/ui-common";
	import type { NDKUser, Hexpubkey, NDKEvent } from "@nostr-dev-kit/ndk";
	import { openModal } from "svelte-modals";
	import type { Readable } from "svelte/motion";

    export let user: NDKUser;
    export let tiers: Readable<NDKEvent[]>;
    export let supporters: Readable<NDKEvent[]>;

    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    $: if (supporters && $supporters) {
        for (const supportEvent of $supporters) {
            supportingPubkeys.add(supportEvent.pubkey);
        }
        supportingPubkeys = supportingPubkeys;
    }

    function openSupportModal() {
        openModal(BecomeSupporterModal, { user, tiers });
    }
</script>

<div class="flex items-center">
    <span class="text-sm">
        {supportingPubkeys?.size}
        Faaans
    </span>
    <div class="flex -space-x-4 ml-4">
        {#each supportingPubkeys as supportingPubkey (supportingPubkey)}
            <Avatar pubkey={supportingPubkey} class="w-10 h-10 border-2 border-black" />
        {/each}
        {$tiers.length}

    </div>

    <div class="ml-4">
        <button class="button px-6" on:click={openSupportModal}>Become a Faaan</button>
    </div>
</div>