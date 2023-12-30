<script lang="ts">
	import { possibleTerms, type Term } from "$utils/term";
    import Input from "$components/Forms/Input.svelte";
	import { Trash } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import { currencySymbol, possibleCurrencies } from "$utils/currency";

    export let value: ["amount", string, string, string];
    export let currency: string = "USD";
    export let amount: string;
    export let term: Term = "monthly";

    amount = amountFromTag(value[1], value[2]);
    currency = value[2];
    term = value[3] as Term;

    function amountFromTag(value: string, currency: string): string {
        if (currency === "msat")
            return (parseInt(value) / 1000).toString();

        return value;
    }

    function amountForTag(value: string, currency: string): string {
        if (!(parseInt(value) > 0))
            return "0";

        if (currency === "msat")
            return (parseInt(value) * 1000).toString();

        return value;
    }

    $: value = ["amount", amountForTag(amount, currency), currency, term];

    const dispatch = createEventDispatcher();

    function onClick() {
        dispatch("delete");
    }
</script>

<div class="self-stretch justify-start items-center gap-2 inline-flex">
    <Input bind:value={amount} color="black" label="Price" placeholder="Price" class="grow basis-0" />
    <select class="select bg-base-200 text-white border border-base-300" bind:value={currency}>
        {#each possibleCurrencies as currency}
            <option value={currency}>{currencySymbol(currency)}</option>
        {/each}
    </select>
    <select class="select bg-base-200 text-white border border-base-300 flex-grow" bind:value={term}>
        {#each possibleTerms as term}
            <option value={term}>{term}</option>
        {/each}
    </select>
    <button class="w-6 h-6" on:click={onClick}>
        <Trash />
    </button>
</div>