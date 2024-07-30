<script lang="ts">
	import { Button } from '$components/ui/button';
	import { tierAmountToString } from '$lib/events/tiers';
	import { NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
	import { Check } from 'phosphor-svelte';
	import { Readable } from 'svelte/store';

    export let tiers: Readable<NDKSubscriptionTier[]>;
    export let selectedTier: NDKSubscriptionTier | undefined;

    let selectedIndex: number | undefined;
    
    selectedIndex ??= $tiers.length > 1 ? Math.floor($tiers.length / 2) : 0;

    $: selectedTier = (selectedIndex !== undefined ? $tiers[selectedIndex] : undefined);

    function select(index: number) {
        if (selectedIndex === index) {
            selectedIndex = undefined;
        } else {
            selectedIndex = index;
        }
    }

    $: console.log(selectedTier?.rawEvent())
</script>

<div class="flex flex-col items-stretch justify-center gap-2 w-full">
    {#each $tiers as tier, i (tier.id)}
        <button class="
            {selectedIndex === i ?
                'bg-background/80 border-accent'
            :
                'bg-background/80'}
            text-foreground p-6 rounded border-2
        " on:click={() => select(i)}>
            <div class="flex flex-row w-full justify-between">
                <h1 class="mb-0">{tier.title}</h1>

                <h1>
                    {tierAmountToString(tier.amounts[0])}
                </h1>
            </div>
        
            <div class="flex flex-col items-start gap-2 justify-stretch text-foreground w-full">
                <div class="flex flex-col gap-2 grow w-full items-start">
                    
                    <div class="text-muted-foreground">
                        {tier.content}
                    </div>

                    {#if tier.perks.length > 0}
                        <div class="flex flex-col items-start justify-start gap-1 w-full">
                            {#each tier.perks as perk}
                                <div class="flex flex-row gap-1 items-center">
                                    <Check size={20} class="text-accent" />
                                    {perk}
                                </div>
                            {/each}
                        </div>
                    {/if}
                </div>
            </div>
        </button>
    {/each}
</div>