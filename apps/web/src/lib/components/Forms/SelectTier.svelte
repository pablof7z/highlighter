<script lang="ts">
    import { CaretDown } from "phosphor-svelte";
	import { slide } from "svelte/transition";
    let show = false;

    export let tiers: Record<string, boolean> = { "Free": true, "Premium": true, "Exclusive": true };
    let selectedString = "";

    function updateSelectedString(changingTier?: string) {
        // If a tier is being changed, and it's being unchecked, uncheck Free
        if (changingTier && !tiers[changingTier]) {
            tiers["Free"] = false;
        }

        // If Free is selected, select all (the keys are dynamic)
        if (tiers["Free"]) {
            tiers = Object.keys(tiers).reduce((acc, tier) => ({ ...acc, [tier]: true }), {});
        }

        if (Object.keys(tiers).filter(tier => tiers[tier]).length === 3) {
            selectedString = "Free";
            return;
        } else if (Object.keys(tiers).filter(tier => tiers[tier]).length === 0) {
            selectedString = "Select";
            return;
        } else {
            selectedString = Object.keys(tiers).filter(tier => tiers[tier]).join(", ");
        }
    }

    updateSelectedString();
</script>

<div class="w-full flex-col justify-start items-start gap-2 inline-flex">
    <div class="text-white text-base font-medium">Content Tier</div>
    <div class="self-stretch rounded-xl border border-neutral-800 items-start inline-flex bg-transparent flex-col justify-start gap-4">
        <button on:click={() => show = !show} class="text-white text-base px-4 py-3 font-medium w-full text-left flex flex-row justify-between">
            {selectedString}
            <CaretDown color="white"/>
        </button>
        {#if show}
            <div class="flex flex-col gap-3 justify-stretch w-full menu flex-nowrap" transition:slide>
                {#each Object.keys(tiers) as tier}
                    <li>
                        <label class="w-full flex flex-row gap-4">
                            <input type="checkbox" class="checkbox" bind:checked={tiers[tier]} on:change={() => updateSelectedString(tier)} />
                            <span class="w-full">{tier}</span>
                        </label>
                    </li>
                {/each}
            </div>
        {/if}
    </div>
</div>