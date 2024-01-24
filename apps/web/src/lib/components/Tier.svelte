<script lang="ts">
	import { currencyFormat, currencySymbol } from "$utils/currency";
import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Check, Pencil } from "phosphor-svelte";

    export let tier: NDKEvent;
    export let selected: boolean;
    export let term: string = "monthly";

    const name = tier.tagValue("title");
    const description = tier.content;
    // const image = tier.tagValue("image");

    let amount: number | undefined;
    let currency: string;
    let perks = tier.getMatchingTags("perk");

    $: {
        const t = tier.getMatchingTags("amount").find((tag) => tag[3] === term)!;
        amount = parseFloat(t[1]);
        currency = t[2];
    }
</script>

<button on:click
    class="self-stretch !rounded-box justify-between items-start flex-col w-[300px] min-h-[300px] inline-flex h-full bg-base-300"
    class:selected={selected}
>
    <!-- {#if image}
        <figure>
            <img src={image} />
        </figure>
    {/if} -->
    <div class="flex flex-col gap-4 text-neutral-300">
        <div class="flex-col justify-start items-start gap-2 flex w-full">
            <div class="text-2xl font-medium w-full items-start flex group flex-row justify-between text-left title text-neutral-200">
                {name}
            </div>

            <div class="flex group flex-row justify-between items-center w-full border-t border-y py-3 border-white/20 price gap-1">
                <div class="flex flex-row gap-2 items-center">
                    <div class="font-medium text-lg">
                        {currencyFormat(currency, amount)}
                    </div>
                    <span>/</span>
                    <span>{term}</span>
                </div>
            </div>

        </div>
        {#if description}
            <div class="flex-col justify-start items-start gap-4 flex w-full text-left whitespace-pre-line description">
                {description}
            </div>
        {/if}

        {#if perks?.length > 0}
            <div class="flex flex-col gap-2 perks !py-0">
                {#each perks as perk}
                    <div class="flex flex-row gap-2 items-start text-left">
                        <Check class="text-neutral-500 w-6 h-6" weight="bold" />
                        <div>
                            {perk[1]}
                        </div>
                    </div>
                {/each}
            </div>
        {/if}
    </div>
</button>

<style lang="postcss">
    button.selected {
        @apply  border-black;
    }

    .title, .price, .description, .perks {
        @apply py-3 px-5;
    }

    .perks {
        @apply text-sm;
    }
</style>