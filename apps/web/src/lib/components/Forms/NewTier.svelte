<script lang="ts">
	import { Input } from "$components/ui/input";
	import { Textarea } from "$components/ui/textarea";
	import CurrencyInput from "./CurrencyInput.svelte";

    let name: string;
    let description: string;
    let amounts: AmountWithCadence[] = [];

    type AmountWithCadence = {
        amount: string;
        cadence: string;
        currency: string;
    };

    function otherCadenceOption() {
        amounts = [...amounts, { amount: "10", cadence: "monthly", currency: "USD" }];
    }
</script>

<label class="text-foreground text-base font-medium flex flex-col gap-2 items-start border border-neutral-800 px-4 py-3 rounded-xl">
    <div class="w-full flex-col justify-start items-start inline-flex">
        <Input
            bind:value={name}
            placeholder="Title"
        />
        <Textarea
            bind:value={description}
            class="w-full !bg-transparent border border-neutral-800 rounded-xl rounded-t-none resize-none text-lg text-foreground tracking-widest"
            placeholder="Description of this tier"
        />
    </div>

    <span>
        Pricing options
    </span>

    {#each amounts as amount}
        <div class="flex flex-row">
            <CurrencyInput bind:amount={amount.amount} bind:currency={amount.currency} />
            <select bind:value={amount.cadence} class="select">
                <option value="monthly">per month</option>
                <option value="quarterly">per quarter</option>
                <option value="yearly">per year</option>
            </select>
        </div>
    {/each}

    <button on:click={otherCadenceOption} class="button">Add another option</button>
</label>