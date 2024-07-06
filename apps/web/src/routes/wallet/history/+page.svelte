<script lang="ts">
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
    import { checkTokenProofs, walletEvents, walletRelaySet } from "$stores/cashu";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { CashuWallet, CashuMint } from "@cashu/cashu-ts";
	import { NDKEvent, NDKEventId, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { Check, Lightning, TrashSimple } from "phosphor-svelte";
	import { onDestroy } from 'svelte';
	import AvatarWithName from '$components/User/AvatarWithName.svelte';
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import WithItem from '$components/Event/ItemView/WithItem.svelte';
	import { page } from '$app/stores';

    let historyItems: NDKEventStore<NDKEvent>;
    
    $: if ($currentUser && !historyItems)
        historyItems = $ndk.storeSubscribe({
            kinds: [7376 as number], authors: [$currentUser.pubkey]
        }, { groupable: false, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY, rselaySet: walletRelaySet });
    
    onDestroy(() => {
        historyItems?.unsubscribe();
    });
</script>

{#if historyItems && $historyItems}
    {#each $historyItems as item (item.id)}
        <pre>{JSON.stringify(item.tags, null, 4)}</pre>

        <div class="flex flex-col border p-4 gap-4">
            <div class="flex flex-row gap-4">
                <h1 class="flex flex-row gap-1 items-center">
                    <Lightning class="text-accent" size="24" weight="fill" />
                    {item.tagValue("amount")} sats
                </h1>

                <div class="text-xs">{item.tagValue("preimage")}</div>

                {#if item.getMatchingTags("p", "recipient")[0]}
                    <AvatarWithName pubkey={item.getMatchingTags("p", "recipient")[0][1]}>
                        Recipient
                    </AvatarWithName>
                {/if}
            </div>
            {#if item.getMatchingTags("e", "recipient")[0]}
                {item.getMatchingTags("e", "recipient")[0][1]}
                <WithItem tagId={item.getMatchingTags("e", "recipient")[0][1]} let:event>
                    {#if event}
                        <EventWrapper {event} compact />
                    {/if}
                </WithItem>
            {/if}
        </div>
    {/each}
{/if}