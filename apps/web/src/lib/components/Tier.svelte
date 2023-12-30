<script lang="ts">
	import { currencyFormat, currencySymbol } from "$utils/currency";
import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Check, Pencil } from "phosphor-svelte";

    export let tier: NDKEvent;
    export let selected: boolean;
    export let term: string = "monthly";

    const name = tier.tagValue("title");
    const description = tier.content;
    const image = tier.tagValue("image") ?? "https://c10.patreonusercontent.com/4/patreon-media/p/reward/5573765/9d074162251943e5ab33aab20473401b/eyJ3Ijo0MDB9/1.jpg?token-time=2145916800&token-hash=cv0bruLHhMqG8H2k18NhN0rjdHmfeOTTifNxVoRYRNw%3D";

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
    class="card card-compact full-image self-stretch !rounded-3xl border-2 justify-between items-start flex-col w-[300px] min-h-[300px] inline-flex h-full !bg-neutral-100"
    class:selected={selected}
>
    {#if image}
        <figure>
            <img src={image} />
        </figure>
    {/if}
    <div class="card-body lex flex-col gap-4">
        <div class="flex-col justify-start items-start gap-2 flex w-full">
            <div class="text-black text-2xl font-medium w-full items-start flex group flex-row justify-between text-left">
                {name}
            </div>
                <div class="flex group flex-row justify-between items-center w-full">
                    <div class="text-center text-black text-[15px] font-medium">{currencyFormat(currency, amount)}/{term}</div>
                </div>
        </div>
        <div class="flex-col justify-start items-start gap-4 flex w-full text-black text-left whitespace-pre-line">
            {description}
        </div>
        {#if perks?.length > 0}
            <div class="flex flex-col gap-2">
                {#each perks as perk}
                    <div class="flex flex-row gap-2 items-start text-left text-neutral-500">
                        <Check class="text-success w-6 h-6" weight="bold" />
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
</style>