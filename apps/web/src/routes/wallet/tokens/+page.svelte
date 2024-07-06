<script lang="ts">
	import { NDKEventStore } from '@nostr-dev-kit/ndk-svelte';
	import { Button } from "$components/ui/button";
    import { checkTokenProofs, walletEvents, walletRelaySet } from "$stores/cashu";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { NDKCashuToken } from "$utils/cashu/token";
	import { CashuWallet, CashuMint } from "@cashu/cashu-ts";
	import { NDKEventId, NDKSubscriptionCacheUsage } from "@nostr-dev-kit/ndk";
	import { Check, TrashSimple } from "phosphor-svelte";

    const wallet = new CashuWallet(new CashuMint("https://stablenut.umint.cash"));

    let expired: NDKEventId[] = [];
    let notExpired: NDKEventId[] = [];

    let tokens: NDKEventStore<NDKCashuToken>;
    
    $: if ($currentUser && !tokens)
        tokens = $ndk.storeSubscribe({
            kinds: [7375 as number], authors: [$currentUser.pubkey]
        }, { groupable: false, cacheUsage: NDKSubscriptionCacheUsage.ONLY_RELAY, relaysSet: walletRelaySet }, NDKCashuToken);

    async function check(token: NDKCashuToken) {
        const exp = await checkTokenProofs(token, $walletEvents[0])
        if (exp) {
            expired = [...expired, token.id]
        } else {
            notExpired = [...notExpired, token.id]
        }
        console.log(check)
    }

    function del(token: NDKCashuToken) {
        token.delete()
    }
    
</script>

{#if $tokens}
    {#each $tokens as token (token.id)}
        {#if !expired.includes(token.id)}
            <h1>
                {token.amount} sats
                <span class="text-muted-foreground font-light ml-4">({token.proofs.length} proofs)</span>
                {token.onRelays.map(r => r.url).join(", ")}
            </h1>
            <Button on:click={() => check(token)}>
                {#if notExpired.includes(token.id)}
                    <Check size={24} />
                {:else}
                    Check
                {/if}
                
            </Button>
            <Button variant="destructive" on:click={() => del(token)}>
                <TrashSimple />
            </Button>
        {:else}
        expired
        {/if}
    {/each}
{/if}