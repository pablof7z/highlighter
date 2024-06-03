<script lang="ts">
	import SidebarSupporterItem from "$components/Creator/CreatorShell/SidebarSupporterItem.svelte";
	import currentUser from "$stores/currentUser";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
	import { ndk } from "$stores/ndk.js";
    import { Hexpubkey, NDKKind, NDKSubscriptionCacheUsage, NDKSubscriptionReceipt, NDKUser } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";

    export let user: NDKUser;

    onDestroy(() => {
        receipts.unsubscribe();
    })
    
    let tierNames: Record<string, string> = {};
    const tiers = getUserSubscriptionTiersStore();

    $: for (const tier of $tiers) {
        const dTag = tier.dTag!;
        if (!dTag) {
            console.warn("No d tag for tier", tier.rawEvent());
            continue;
        } else {
            tierNames[dTag] = tier.title ?? dTag;
        }
    }
    
    const relaySet = undefined;// getDefaultRelaySet();
    
    const receipts = $ndk.storeSubscribe([
        { kinds: [NDKKind.SubscriptionReceipt], authors: ["73c6bb92440a9344279f7a36aa3de1710c9198b1e9e8a394cd13e0dd5c994c63"]
        },
    ], { relaySet, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY }, NDKSubscriptionReceipt);

    const sortedReceipts = derived(receipts, ($receipts) => {
        const pubkeys: Record<Hexpubkey, NDKSubscriptionReceipt> = {};

        // go through the receipts, get the recipient's pubkey and put the lowest created_at in the pubkey object
        for (const receipt of $receipts) {
            const subscriber = receipt.subscriber?.pubkey;
            if (!subscriber) continue;
            if (!pubkeys[subscriber] || pubkeys[subscriber].created_at! > receipt.created_at!) {
                pubkeys[subscriber] = receipt;
            }
        }

        const sorted: NDKSubscriptionReceipt[] = Object.keys(pubkeys).sort((a, b) => {
            if (pubkeys[a].created_at! < pubkeys[b].created_at!) return -1;
            if (pubkeys[a].created_at! > pubkeys[b].created_at!) return 1;
            return 0;
        }).map((pubkey) => pubkeys[pubkey]);
        return sorted;
    });
</script>

    {#if sortedReceipts && $sortedReceipts?.length > 0 && false}
        <div class="flex flex-col">
            <h2 class="text-white font-semibold text-lg px-4 pb-2">
                Top Supporters
            </h2>
            <div class="flex flex-col discussion-wrapper w-full">
                {#each $sortedReceipts.slice(10, 13) as receipt, i (receipt.subscriber.pubkey)}
                    <SidebarSupporterItem pubkey={receipt.subscriber.pubkey} {tiers} {tierNames} position={i} creatorPubkey={user?.pubkey} {receipt} />
                {/each}
            </div>
        </div>
    {:else if user.pubkey === $currentUser?.pubkey}
        <div class="h-full flex flex-row items-center justify-center p-6">
            Get more supporters by creating an enticing proposal and sharing your profile!
        </div>
    {/if}