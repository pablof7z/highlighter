<!--
    This is a component that renders a list of current and past supporters.

    It's intended to be displayed for the creator.
-->
<script lang="ts">
	import { getUserSubscriptionTiersStore, getUserSupporters } from "$stores/user-view";
	import { creatorRelayPubkey } from "$utils/const";
	import { NDKKind, type Hexpubkey, NDKSubscription, NDKSubscriptionReceipt, NDKSubscriptionStart, NDKUser, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { derived, type Readable } from "svelte/store";
	import { getDefaultRelaySet } from '$utils/ndk';
	import SupporterListItem from "$components/Supporters/SupporterListItem.svelte";
	import SidebarSupporterItem from "./SidebarSupporterItem.svelte";

    export let user: NDKUser;

    let supporters: Readable<Record<Hexpubkey, string|true>> | undefined = undefined;
    let tierNames: Record<string, string> = {};

    // onMount(() => {
        supporters = getUserSupporters();
    // });

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

    const relaySet = getDefaultRelaySet();
    const receipts = $ndk.storeSubscribe([
        { kinds: [NDKKind.SubscriptionReceipt], "#p": [user.pubkey], authors: [creatorRelayPubkey] },
    ]
    , { relaySet, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY }, NDKSubscriptionReceipt);

    onDestroy(() => {
        receipts.unsubscribe();
    })

    const sortedReceipts = derived( receipts, ($receipts) => {
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

{#if sortedReceipts && $sortedReceipts?.length > 0}
    <div class="flex flex-col">
        <h2 class="text-foreground font-semibold text-lg px-4 pb-2">
            Top Supporters
        </h2>
        <div class="flex flex-col discussion-wrapper w-full">
            {#each $sortedReceipts as receipt, i (receipt.subscriber.pubkey)}
                <SidebarSupporterItem pubkey={receipt.subscriber.pubkey} {tiers} {tierNames} position={i} creatorPubkey={user?.pubkey} {receipt} />
            {/each}
        </div>
    </div>
{/if}