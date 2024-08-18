<script lang="ts">
	import * as Card from "$components/ui/card";
	import { currencyFormat } from "$utils/currency";
	import { termToShort } from "$utils/term";
    import { NDKSubscriptionAmount, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";

    export let tier: NDKSubscriptionTier;
    export let currency: string | undefined;

    let amounts: NDKSubscriptionAmount[] = [];

    $: {
        amounts = tier.amounts
            .filter(amount => amount.currency === currency);
        if (amounts.length === 0) {
            amounts = tier.amounts;
        }
    }
</script>


<Card.Root class="bg-secondary">
    <Card.Header class="p-4">
        <Card.Title>{tier.title}</Card.Title>
        <Card.Description>
            <div>
                {tier.content}
            </div>

            {#if amounts.length === 1}
                <div class="text-4xl text-foreground font-bold">
                    {currencyFormat(amounts[0].currency, amounts[0].amount)}
                    <div class="font-light inline">
                        /
                        {termToShort(amounts[0].term)}
                    </div>
                </div>
            {:else}
                {#each amounts as amount}
                    <div>
                        {amount.amount} {amount.currency}
                    </div>
                {/each}
            {/if}
        </Card.Description>
    </Card.Header>
    <Card.Content class="p-4 md:pt-0">
        {tier.content}
    </Card.Content>
</Card.Root>