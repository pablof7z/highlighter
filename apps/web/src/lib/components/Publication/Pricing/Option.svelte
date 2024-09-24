<script lang="ts">
	import { NDKSubscriptionAmount } from '@nostr-dev-kit/ndk';
	import { tierAmountToString } from "$lib/events/tiers";
    import RadioButton from "$components/Forms/RadioButton.svelte";

    export let amounts: NDKSubscriptionAmount[];
    export let selection: string;
    export let i: number;
</script>

<RadioButton color="gold" skipCheck bind:currentValue={selection} value={i.toString()}>
    {#each amounts as amount, j}
        {#if j === 0}
            <div class="text-4xl font-bold">
                {tierAmountToString(amount)}
            </div>
        {:else}
            <div class="text-muted-foreground text-xs whitespace-nowrap">
                {tierAmountToString(amount)}
            </div>
        {/if}
    {/each}
</RadioButton>
