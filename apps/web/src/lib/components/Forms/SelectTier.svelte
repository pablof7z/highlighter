<script lang="ts">
	import TiersModal from '$modals/TiersModal.svelte';
    import { CaretDown, PlusCircle } from "phosphor-svelte";
	import { slide } from "svelte/transition";
	import type { TierSelection } from "$lib/events/tiers";
    import { createEventDispatcher, onMount } from "svelte";
	import { openModal } from "svelte-modals";

    export let show = false;
    export let skipTitle = false;
    export let subtitle: string | undefined = undefined;
    export let tiers: TierSelection;
    let selectedString = "";

    const dispatch = createEventDispatcher();

    function updateSelectedString(changingTier?: string) {
        // If a tier is being changed, and it's being unchecked, uncheck Free
        console.log({changingTier, selected: tiers[changingTier]?.selected});
        if (
            changingTier &&
            changingTier !== "Free" && !tiers[changingTier].selected) {
            tiers["Free"].selected = false;
            tiers = tiers
            console.log("unselecting Free")
        }

        // If Free is selected, select all (the keys are dynamic)
        if (tiers["Free"].selected) {
            console.log("Free is selected, selecting all")
            tiers = Object.keys(tiers)
                .reduce((acc, id) => ({ ...acc, [id]: { name: tiers[id].name, selected: true } }), {});
        }

        if (Object.keys(tiers).filter(tier => tiers[tier].selected).length === Object.keys(tiers).length) {
            selectedString = "Free";
        } else if (Object.keys(tiers).filter(tier => tiers[tier].selected).length === 0) {
            selectedString = "Select";
        } else {
            selectedString = Object.keys(tiers)
                .filter(tier => tiers[tier].selected)
                .map(tier => tiers[tier].name)
                .join(", ");
        }

        dispatch("changed", tiers);
    }

    onMount(updateSelectedString);

    function addNewTier() {
        openModal(TiersModal);
    }
</script>

<div class="w-full flex-col justify-start items-start gap-2 inline-flex">
    {#if !skipTitle}
        <div class="text-white text-xl font-medium">Content Tier</div>
    {/if}
    {#if subtitle}
        <div class="text-white/50 font-thin">
            {subtitle}
        </div>
    {/if}
    <div class="self-stretch rounded-xl border border-neutral-800 items-start inline-flex bg-transparent flex-col justify-start gap-0">
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
                            <input type="checkbox" class="checkbox" bind:checked={tiers[tier].selected} on:change={(e) => updateSelectedString(tier)} />
                            <span class="w-full">{tiers[tier].name}</span>
                        </label>
                    </li>
                {/each}
                <li class="border-t border-base-300">
                    <button class="text-white w-full flex flex-row gap-4" on:click={addNewTier}>
                        Add a new tier
                    </button>
                </li>
            </div>
        {/if}
    </div>
</div>