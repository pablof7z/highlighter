<script lang="ts">
	import BecomeSupporterModal from "$modals/BecomeSupporterModal.svelte";
	import { Avatar, user as currentUser } from "@kind0/ui-common";
	import type { NDKUser, Hexpubkey, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { PencilSimple, Share } from "phosphor-svelte";
	import { openModal } from "svelte-modals";
	import type { Readable } from "svelte/motion";

    export let user: NDKUser;
    export let tiers: Readable<NDKArticle[]>;
    export let supporters: Readable<Record<Hexpubkey, string | undefined>>;

    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    $: if (supporters && $supporters) {
        supportingPubkeys = new Set(Object.keys($supporters));
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

<div class="flex items-center gap-4 max-sm:w-full">
    {#if supportingPubkeys?.size > 0}
        <span class="text-sm whitespace-nowrap">
            {supportingPubkeys?.size}
            Faaans
        </span>
        <div class="flex -space-x-4 ml-4 w-fit">
            {#each Array.from(supportingPubkeys).slice(0, 10) as supportingPubkey (supportingPubkey)}
                <div class="flex-none w-10">
                    <Avatar pubkey={supportingPubkey} class="w-10 h-10 border-2 border-black flex-none" />
                </div>
            {/each}
        </div>
    {/if}

    {#if !isSupporter}
        <button class="whitespace-nowrap button px-6 w-full" on:click={openSupportModal}>
            <PencilSimple class="mr-2" />
            Subscribe
        </button>
    {:else}
        <!-- <button class="whitespace-nowrap button px-6" on:click={openShareModal}>
            <Share class="mr-2" />
            Share
        </button> -->
    {/if}
</div>