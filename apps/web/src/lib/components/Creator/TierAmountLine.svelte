<script lang="ts">
	import { possibleTerms, type Term } from "$utils/term";
    import Input from "$components/Forms/Input.svelte";
	import { Trash } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import { currencySymbol, possibleCurrencies } from "$utils/currency";
	import CurrencySelect from "./CurrencySelect.svelte";
	import TermSelect from "./TermSelect.svelte";
	import GlassyInput from "$components/Forms/GlassyInput.svelte";

    export let value: ["amount", string, string, string];
    export let currency: string;
    export let amount: string;
    export let term: Term | "" = "";
    export let forceOpen = false;
    export let complete: boolean;

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

    let open: boolean;

    $: open = forceOpen || !currency || !amount || !term;
    $: complete = !!currency && !!amount && !!term;
</script>

<div
    class="self-stretch justify-start items-center gap-2 inline-flex border-base-300 rounded-box"
    class:border={open}
    class:bg-base-300={open}
    class:p-4={open}
>
    {#if !currency || !term || forceOpen}
        <div class="flex flex-col gap-4 relative w-full">
            <div class="flex flex-row gap-1 items-center">
                <div class="text-sm font-medium text-white w-full">Tier price</div>
                <div
                    class="
                        flex flex-row gap-2 bg-base-200 rounded-2xl
                        {(!amount || !currency) ? "border border-red-800/50" : ""}
                    "
                >
                    <Input bind:value={amount} color="black" label="Price" placeholder="Price" class="grow basis-0 text-sm text-right !w-20 shrink !border-none" />
                    <div class="flex-grow">
                        <CurrencySelect bind:currency class="bg-transparent !border-none !outline-none" />
                    </div>
                </div>
            </div>

            <div class="flex flex-row gap-1 items-center">
                <div class="text-sm font-medium text-white w-full">
                    How often should supporters pay you?
                </div>
                <div class="
                    {!term ? "border border-red-800/50" : ""}
                ">
                    <TermSelect bind:term />
                </div>
            </div>

            <button class="w-6 h-6 text-sm self-end" on:click={onClick}>
                <Trash />
            </button>
        </div>
    {:else}
        <Input bind:value={amount} color="black" label="Price" placeholder="Price" class="basis-0 text-right w-[100px]" />
        <div class="shrink">
            <CurrencySelect bind:currency />
        </div>

        <div class="shrink">
            <TermSelect bind:term />
        </div>

        <div class="max-sm:hidden flex-grow"></div>

        <button class="w-6 h-6 text-sm" on:click={onClick}>
            <Trash />
        </button>
    {/if}
</div>