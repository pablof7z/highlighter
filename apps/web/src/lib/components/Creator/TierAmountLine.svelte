<script lang="ts">
    import Input from "$components/Forms/Input.svelte";
	import Trash from "phosphor-svelte/lib/Trash";
    import { createEventDispatcher } from "svelte";
	import CurrencySelect from "./CurrencySelect.svelte";
	import TermSelect from "./TermSelect.svelte";
	import type { NDKSubscriptionAmount } from "@nostr-dev-kit/ndk";

    export let value: NDKSubscriptionAmount;
    export let forceOpen = false;
    export let complete: boolean | undefined = undefined;

    let amount = ((value.currency === 'msat') ? (value.amount/1000) : (value.amount/100)).toString();

    $: value.amount = parseFloat(amount) * (value.currency === 'msat' ? 1000 : 100);

    function blurInput() {
        // if the currency is USD or EUR, make it into a float with 2 decimals
        if (value.currency === "USD" || value.currency === "EUR") {
            amount = parseFloat(amount).toFixed(2);
        }
    }

    const dispatch = createEventDispatcher();

    function onClick() {
        dispatch("delete");
    }

    let open: boolean;

    $: open = forceOpen || !(value.currency && value.term && value.amount);
    $: complete = !!(value.currency && value.term && value.amount);
</script>

<div
    class="
        w-full
        self-stretch justify-start items-center gap-2 inline-flex rounded-box
    "
>
    {#if !(value.currency && value.term && value.amount) || forceOpen}
    <section class="settings w-full relative" class:!p-0={!open}>
        <div class="flex flex-row gap-2 w-full">
            <div class="field">
                <div class="title" class:hidden={!open}>
                    Tier Price
                </div>
                <div
                    class="
                        flex flex-row bg-base-200 rounded-2xl
                        {(!amount || !value.currency) ? "shadow shadow-red-800/50" : ""}
                    "
                >
                    <Input on:blur={blurInput} bind:value={amount} color="black" label="Price" placeholder="Price" class="grow basis-0 text-sm text-right !w-20 !bg-white/10 shrink !border-none rounded-l-2xl rounded-r-none" />
                    <div class="flex-grow">
                        <CurrencySelect bind:currency={value.currency} class="!bg-black/10 rounded-l-none border-0 pl-2 ml-0 !outline-none" />
                    </div>
                </div>
            </div>

            <div class="field">
                <div class="title" class:hidden={!open}>
                    Cadence
                </div>
                <TermSelect bind:term={value.term} class={!value.term ? "shadow shadow-red-800/50 rounded-box" : ""} />
            </div>
        </div>

        <button class="w-6 h-6 text-sm absolute top-2 right-2" on:click={onClick}>
            <Trash />
        </button>

    </section>
    {:else}
        <Input bind:value={amount} on:blur={blurInput} color="black" label="Price" placeholder="Price" class="basis-0 text-right flex-none !w-[150px] !bg-white/5" />
        <div class="shrink">
            <CurrencySelect bind:currency={value.currency} />
        </div>

        <div class="shrink">
            <TermSelect bind:term={value.term} />
        </div>

        <div class="max-sm:hidden flex-grow"></div>

        <button class="w-6 h-6 text-sm" on:click={onClick}>
            <Trash />
        </button>
    {/if}
</div>