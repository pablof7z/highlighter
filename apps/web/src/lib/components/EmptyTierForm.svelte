<script lang="ts">
	import { termToShort, type Term, possibleTerms } from "$utils/term";
    import Input from '$components/ui/input/input.svelte';

    export let currency: string = 'USD';
    export let term: Term;
    export let selectedAmount: number | undefined = 5;

    let amount: string = selectedAmount ? selectedAmount.toString() : "";

    $: if (parseInt(amount)) {
        selectedAmount = parseInt(amount);

        if (selectedAmount < 0) {
            selectedAmount = 1;
            amount = "1";
        }

        if (currency === "msat") {
            selectedAmount *= 1000;
        } else {
            selectedAmount *= 100;
        }
    }
</script>

<button on:click
    class="tier"
>
    <div class="title">
        <h1>
            Supporter
        </h1>

        <div class="description">
            Choose the amount you want to support this creator with
        </div>
    </div>
    <div class="flex flex-row gap-4">
        <Input
            type="number"
            bind:value={amount}
            autofocus={true}
        />

        <select
            class="select select-primary bg-inherit border-white/10 focus:text-inherit focus:!outline-none"
            bind:value={currency}
        >
            <option value="USD">USD/{termToShort(term)}</option>
            <option value="msat">sats/{termToShort(term)}</option>
        </select>
    </div>
</button>
