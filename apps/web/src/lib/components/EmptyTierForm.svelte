<script lang="ts">
	import { randomVideoThumbnail } from "$utils/skeleton";
	import { termToShort, type Term, possibleTerms } from "$utils/term";
	import type { UserProfileType } from "../../app";
    import Input from "./Forms/Input.svelte";

    export let currency: string = 'USD';
    export let term: Term;
    export let selectedAmount: number | undefined = 5;
    export let userProfile: UserProfileType;

    let amount: string = selectedAmount ? selectedAmount.toString() : "";

    $: if (parseInt(amount)) {
        selectedAmount = parseInt(amount);

        if (selectedAmount < 0) {
            selectedAmount = 1;
            amount = "1";
        }

        if (currency === "msat") {
            selectedAmount *= 1000;
        }
    }
</script>

<button on:click
    class="card card-compact full-image self-stretch !rounded-3xl border-2 justify-between items-start flex-col w-[300px] min-h-[300px] inline-flex h-full !bg-neutral-100"
>
    {#if userProfile?.banner || userProfile?.image}
        <figure>
            <img src={userProfile.banner || userProfile?.image} />
        </figure>
    {/if}
    <div class="card-body lex flex-col gap-4">
        <div class="flex-col justify-start items-start gap-2 flex w-full">
            <h1 class="!text-black text-2xl font-medium w-full items-start flex group flex-row justify-between text-left">
                Supporter
            </h1>

            <div class="flex group flex-col text-left gap-4 text-black text-base items-center">
                Choose the amount you want to support this creator with

                <div class="flex flex-row gap-4">
                    <Input
                        type="number"
                        class="w-full !bg-white !text-black round text-center"
                        bind:value={amount}
                        autofocus={true}
                    />

                    <select
                        class="select select-primary bg-inherit border-inherit focus:bg-inherit focus:text-inherit"
                        bind:value={currency}
                    >
                        <option value="USD">USD/{termToShort(term)}</option>
                        <option value="msat">sats/{termToShort(term)}</option>
                    </select>
                </div>
            </div>
        </div>
    </div>
</button>
