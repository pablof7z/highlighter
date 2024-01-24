<script lang="ts">
	import type { Term } from "$utils/term";
    import Input from "$components/Forms/Input.svelte";
	import Trash from "phosphor-svelte/lib/Trash";
    import { createEventDispatcher } from "svelte";
	import CurrencySelect from "./CurrencySelect.svelte";
	import TermSelect from "./TermSelect.svelte";

    export let value: ["amount", string, string, string];
    export let currency: string;
    export let amount: string;
    export let term: Term | "" = "";
    export let forceOpen = false;
    export let complete: boolean;

    function blurInput() {
        // if the currency is USD or EUR, make it into a float with 2 decimals
        if (currency === "USD" || currency === "EUR") {
            amount = parseFloat(amount).toFixed(2);
        }
    }

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
    class="
        self-stretch justify-start items-center gap-2 inline-flex border-base-300 rounded-box
        {open ? "!bg-white/10 " : ""}
    "
    class:border={open}
    class:p-4={open}
>
    {#if !currency || !term || forceOpen}
        <div class="flex flex-col gap-4 relative w-full">
            <div class="flex flex-row gap-1 items-center">
                <div class="text-sm font-medium text-white w-full">Tier price</div>
                <div
                    class="
                        flex flex-row bg-base-200 rounded-2xl
                        {(!amount || !currency) ? "shadow shadow-red-800/50" : ""}
                    "
                >
                    <Input on:blur={blurInput} bind:value={amount} color="black" label="Price" placeholder="Price" class="grow basis-0 text-sm text-right !w-20 !bg-white/10 shrink !border-none rounded-l-2xl rounded-r-none" />
                    <div class="flex-grow">
                        <CurrencySelect bind:currency class="!bg-black/10 rounded-l-none border-0 pl-2 ml-0 !outline-none" />
                    </div>
                </div>
            </div>

            <div class="flex flex-row gap-1 items-center">
                <div class="text-sm font-medium text-white w-full">
                    How often should supporters pay you?
                </div>
                <div class="

                ">
                    <TermSelect bind:term class={!term ? "shadow shadow-red-800/50 rounded-box" : ""} />
                </div>
            </div>

            <button class="w-6 h-6 text-sm self-end" on:click={onClick}>
                <Trash />
            </button>
        </div>
    {:else}
        <Input bind:value={amount} on:blur={blurInput} color="black" label="Price" placeholder="Price" class="basis-0 text-right flex-none !w-[100px]" />
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