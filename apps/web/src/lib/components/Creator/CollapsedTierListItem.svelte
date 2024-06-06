<script lang="ts">
	import { currencyFormat } from "$utils/currency";
	import { termToShort } from "$utils/term";
	import type { NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { Check } from "phosphor-svelte";

    export let tier: NDKSubscriptionTier;
</script>

<button
    class="border border-border px-4 py-3 flex flex-col gap-2 hover:bg-white/10 transition-all duration-300 w-full rounded-md"
    on:click
>
    <div class="flex flex-row justify-between whitespace-nowrap truncate w-full">
        <h1 class="text-xl font-semibold">
            {tier.title}
        </h1>

        {#if tier.getMatchingTags("amount")}
            <h2 class="text-xl font-semibold text-green-500">
                {currencyFormat(
                    tier.getMatchingTags("amount")[0][2],
                    parseInt(tier.getMatchingTags("amount")[0][1])
                )}/{termToShort(tier.getMatchingTags("amount")[0][3])}
            </h2>
        {/if}
    </div>

    {#if tier.content.length > 0 || tier.getMatchingTags("perk").length > 0}
        <ul class="text-xs flex flex-col items-start gap-2">
            {#if tier.content.length > 0}
                <li class="text-left">
                    {tier.content}
                </li>
            {/if}
            {#each tier.getMatchingTags("perk") as perkTags}
                <li class="flex flex-row items-center">
                    <Check class="w-5 h-5 mr-2 text-green-500" weight="duotone" />
                    {perkTags[1]}
                </li>
            {/each}
        </ul>
    {/if}
</button>

