<script lang="ts">
	import TiersModal from "$modals/TiersModal.svelte";
	import { user } from "@kind0/ui-common";
    import { CaretDown, Gear, PlusCircle } from "phosphor-svelte";
	import { openModal } from "svelte-modals";
	import { slide } from "svelte/transition";

    export let show = false;
    export let skipTitle = false;
    export let tiers: Record<string, boolean>;
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

        if (Object.keys(tiers).filter(tier => tiers[tier]).length === Object.keys(tiers).length) {
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

    $: if (tiers) {
        updateSelectedString();
    }

    // function addNewTier() {
    //     openModal(TiersModal);
    // }
</script>

<div class="w-full flex-col justify-start items-start gap-2 inline-flex">
    {#if !skipTitle}
        <div class="text-white text-base font-medium">Content Tier</div>
    {/if}
    <div class="self-stretch rounded-xl border border-neutral-800 items-start inline-flex bg-transparent flex-col justify-start gap-4">
        <button on:click={() => show = !show} class="text-white text-base px-4 py-3 font-medium w-full text-left flex flex-row justify-between">
            <div class="flex flex-row items-end gap-4">
                {selectedString}
                {#if selectedString === "Free"}
                    <div class="font-light text-sm opacity-50">
                        Content will be publicly visible
                    </div>
                {/if}
            </div>
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
                <!-- <li class="border-t border-base-300">
                    <button class="w-full flex flex-row gap-4" on:click={addNewTier}>
                        <PlusCircle size="22" />
                        Add a new tier
                    </button>
                </li> -->
            </div>
        {/if}
    </div>
</div>