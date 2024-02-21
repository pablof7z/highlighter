<script lang="ts">
	import { currencyFormat, } from "$utils/currency";
    import type { NDKSubscriptionTier, NDKSubscriptionAmount } from "@nostr-dev-kit/ndk";
	import { Check } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";


    export let tier: NDKSubscriptionTier;
    export let selected: boolean;
    export let currency: string;
    export let term: string;

    let activeCurrency = currency;

    const dispatch = createEventDispatcher();

    const name = tier.title ?? tier.dTag;
    const description = tier.content;
    // const image = tier.tagValue("image");

    let amounts = tier.amounts;

    let amount: number | undefined;

    let selectedAmountTag: NDKSubscriptionAmount;

    $: {
        let changingCurrency = false;

        if (activeCurrency !== currency) {
            activeCurrency = currency;
            selectedAmountTag = undefined;
            term = undefined;
            amount = undefined;
            changingCurrency = true;
        }

        if (selectedAmountTag) {
            term = selectedAmountTag.term;
            amount = selectedAmountTag.amount;
        }

        selectedAmountTag =
            amounts.find((a) => a.currency === currency && a.term === term)
            ?? amounts.find((a) => a.currency === currency )
            ?? amounts[0];

        if (!term) term = selectedAmountTag.term;
        if (!amount) amount = selectedAmountTag.amount;

        if (changingCurrency) {
            dispatch("changed", selectedAmountTag);
        }
    }

    let availableAmounts: NDKSubscriptionAmount[];

    $: availableAmounts = amounts.filter((a) => a.currency === currency);

    function onChange() {
        dispatch("changed", selectedAmountTag);
    }
</script>

<div class="tier-container snap-center" class:selected={selected}>
    <button on:click={onChange}
        class="tier"
        class:selected={selected}
    >
        <div class="title">{name}</div>

        <div class="price">
            <span class="price">
                {currencyFormat(currency, amount)}
            </span>
            {#if availableAmounts.length > 1}
                <select bind:value={selectedAmountTag} on:change={onChange}>
                    {#each availableAmounts as amount}
                        <option value={amount}>
                            {amount.term}
                        </option>
                    {/each}
                </select>
            {:else}
                <span class="term">{term}</span>
            {/if}
        </div>

        <div class="description-and-perks">
            {#if description}
                <div class="description">
                    {description}
                </div>
            {/if}

            {#if tier.perks?.length > 0}
                <div class="flex flex-col gap-2 perks">
                    {#each tier.perks as perk}
                        <div class="perk">
                            <i><Check class="w-5 h-5 {selected ? 'text-success' : ''}" weight="bold" /></i>
                            <span>{perk}</span>
                        </div>
                    {/each}
                </div>
            {/if}
        </div>
    </button>
</div>