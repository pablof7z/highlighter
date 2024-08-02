<script lang="ts">
    import Input from '$components/ui/input/input.svelte';
	import Trash from "phosphor-svelte/lib/Trash";
    import { createEventDispatcher } from "svelte";
	import CurrencySelect from "./CurrencySelect.svelte";
	import TermSelect from "./TermSelect.svelte";
	import type { NDKIntervalFrequency, NDKSubscriptionAmount } from "@nostr-dev-kit/ndk";
	import { tierAmountToString } from '$lib/events/tiers';
	import { Button } from '$components/ui/button';
	import { CheckFat, TrashSimple } from 'phosphor-svelte';

    export let forceOpen = false;
    export let complete: boolean | undefined = undefined;

    export let amount: NDKSubscriptionAmount;
    export let currency: string = amount.currency;
    export let term: NDKIntervalFrequency = amount.term;

    let hasFocus = false;
    
    let amountS = amount?.amount?.toString() ?? "100";
    if (amount.currency === "msats") amountS = (amount.amount / 1000).toString();
    else if (amount.currency === "sats") amountS = (amount.amount / 100).toString();

    $: {
        amount.amount = Number(amountS);
        amount.currency = currency;
        amount.term = term;

        amount.amount *= amount.currency === "msats" ? 10000 : 100;
        
        amount = amount;
    }

    $: if (isNaN(amount.amount)) amount.amount = 0;

    function blurInput() {
        // if the currency is USD or EUR, make it into a float with 2 decimals
        if (currency === "USD" || currency === "EUR") {
            amountS = parseFloat(amountS).toFixed(2);
            if (amountS === "NaN") amountS = "0";
        } else if (currency === "msats") {
            amountS = parseFloat(amountS).toFixed(0);
            if (amountS === "NaN") amountS = "0";
        } else {
            amountS = parseFloat(amountS).toFixed(0);
            if (amountS === "NaN") amountS = "0";
        }

        hasFocus = false;
    }

    blurInput();

    const dispatch = createEventDispatcher();

    function onClick() {
        dispatch("delete");
    }

    let open: boolean;

    $: open = hasFocus || forceOpen || !(currency && term && amount.amount) || amount.amount === 0;
    $: complete = !!(currency && term && amount);
</script>

<div
    class="
        w-full
        self-stretch justify-start items-center gap-2 inline-flex rounded
    "
>
    {#if open}
        <div class="flex flex-col items-center w-full">
            <div class="flex flex-row items-center">
                <Input
                    bind:value={amountS}
                    on:focus={() => hasFocus = true}
                    on:blur={blurInput}
                    placeholder="10"
                    class="text-7xl border-0 font-bold w-full h-full text-right focus:!ring-0 focus:!outline-none focus:!shadow-0 focus-visible:!ring-0" />
    
                <div class="flex flex-col w-1/2">
                    <CurrencySelect bind:currency class="!w-fit text-xl border-0" />
                    <TermSelect bind:term class="!w-fit border-0 mr-2 text-muted-foreground" />
                </div>
            </div>
            
            <div class="flex flex-row gap-4 items-center mt-4 w-fit" class:hidden={forceOpen}>
                <Button size="sm" on:click={() => forceOpen = false}>
                    <CheckFat weight="fill" />
                </Button>
                <Button variant="secondary" size="sm" on:click={() => dispatch('delete')}>
                    <TrashSimple weight="fill" />
                </Button>

            </div>
        </div>
        
        <div class="flex flex-row gap-2 w-full hidden">
            <div class="field">
                <div
                    class="
                        flex flex-row bg-foreground/10 rounded-2xl
                        {(!amount || !currency) ? "shadow shadow-red-800/50" : ""}
                    "
                >
                    <div class="flex-grow">
                        <CurrencySelect bind:currency={currency} class="!bg-black/10 rounded-l-none border-0 pl-2 ml-0 !outline-none" />
                    </div>
                </div>
            </div>

            <TermSelect bind:term={term} />
        </div>

        <button class="w-6 h-6 text-sm absolute top-2 right-2" on:click={onClick}>
            <Trash />
        </button>
    {:else}
        <button on:click={() => forceOpen = true}>
            {tierAmountToString(amount)}
        </button>
    {/if}
</div>