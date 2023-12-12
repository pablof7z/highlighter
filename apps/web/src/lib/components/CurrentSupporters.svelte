<script lang="ts">
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { Avatar, user as currentUser } from "@kind0/ui-common";
	import type { NDKUser, Hexpubkey, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { Share } from "phosphor-svelte";
	import { openModal } from "svelte-modals";
	import type { Readable } from "svelte/motion";

    export let user: NDKUser;
    export let tiers: Readable<NDKArticle[]>;
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

    function openShareModal() {
        // openModal(ShareModal, { user });
    }

    let isCurrentUser: boolean;
    let isSupporter: boolean;

    $: isCurrentUser = user && user?.pubkey === $currentUser?.pubkey;
    $: isSupporter = supportingPubkeys.has($currentUser?.pubkey);
</script>

<div class="flex items-center gap-4">
    {#if supportingPubkeys?.size > 0}
        <span class="text-sm whitespace-nowrap">
            {supportingPubkeys?.size}
            Faaans
        </span>
    {/if}
    <div class="flex -space-x-4 ml-4">
        {#each Array.from(supportingPubkeys).slice(0, 10) as supportingPubkey (supportingPubkey)}
            <Avatar pubkey={supportingPubkey} class="w-10 h-10 border-2 border-black" />
        {/each}
    </div>

    {#if !isSupporter}
        <button class="whitespace-nowrap button px-6" on:click={openSupportModal}>Become a Faaan</button>
    {:else}
        <button class="whitespace-nowrap button px-6" on:click={openShareModal}>
            <Share class="mr-2" />
            Share
        </button>
    {/if}
</div>