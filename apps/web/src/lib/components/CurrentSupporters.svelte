<script lang="ts">
	import type { NDKUser, Hexpubkey } from "@nostr-dev-kit/ndk";
	import Avatar from "./User/Avatar.svelte";
	import currentUser from "$stores/currentUser";

    export let user: NDKUser;
    export let supporters: Record<Hexpubkey, string | undefined | true>;

    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();

    $: if (supporters) {
        supportingPubkeys = new Set(Object.keys(supporters));
    }

    let isCurrentUser: boolean;
    let isSupporter: boolean;

    $: isCurrentUser = user && user?.pubkey === $currentUser?.pubkey;
    $: isSupporter = supportingPubkeys.has($currentUser?.pubkey);
</script>

<div class="flex items-center gap-4 max-sm:w-full">
    {#if supportingPubkeys?.size > 0}
        <div class="flex -space-x-4 ml-4 w-fit">
            {#each Array.from(supportingPubkeys).slice(0, 10) as supportingPubkey (supportingPubkey)}
                <div class="flex-none w-10">
                    <Avatar pubkey={supportingPubkey} class="w-10 h-10 border-2 border-black flex-none" />
                </div>
            {/each}
        </div>
        <span class="text-xs text-neutral-500 whitespace-nowrap">
            {supportingPubkeys?.size}
            Supporter{supportingPubkeys?.size > 1 ? "s" : ""}
        </span>
    {/if}

    {#if !isSupporter}

    {:else}
        <!-- <button class="whitespace-nowrap button px-6" on:click={openShareModal}>
            <Share class="mr-2" />
            Share
        </button> -->
    {/if}
</div>