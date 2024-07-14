<script lang="ts">
	import { Button } from "$components/ui/button";
    import { _walletTokens, activeWallet, activeWalletTokens, checkTokenProofs, deletedTokens } from "$stores/cashu";
	import { NDKCashuToken } from "$utils/cashu/token";
	import { NDKEventId } from "@nostr-dev-kit/ndk";
	import { Check, TrashSimple } from "phosphor-svelte";

    let expired: NDKEventId[] = [];
    let notExpired: NDKEventId[] = [];

    async function check(token: NDKCashuToken) {
        const exp = await checkTokenProofs(token);
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

{#each $_walletTokens as [walletId, tokens]}
    <h1>{walletId}</h1>

    <div class="ml-12">
        {#each tokens as token}
            <div class="ml-12" class:opacity-50={$deletedTokens.has(token.id)}>
                {token.mint}
                {#each token.proofs as proof}
                    <div class="ml-12">
                        {proof.amount} ({proof.id})
                    </div>
                {/each}
            </div>
        {/each}
    </div>
{/each}

{#each $activeWalletTokens as token (token.id)}
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