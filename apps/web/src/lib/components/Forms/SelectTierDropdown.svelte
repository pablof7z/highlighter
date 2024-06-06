<script lang="ts">
	import TiersModal from '$modals/TiersModal.svelte';
    import { CaretDown } from "phosphor-svelte";
	import type { TierSelection } from "$lib/events/tiers";
    import { createEventDispatcher, onMount } from "svelte";
	import { openModal } from '$utils/modal';

    export let show = false;
    export let tiers: TierSelection;
    let selectedString = "";

    const dispatch = createEventDispatcher();

    function updateSelectedString(changingTier?: string) {
        // If a tier is being changed, and it's being unchecked, uncheck Free
        if (
            changingTier &&
            changingTier !== "Free" && !tiers[changingTier].selected) {
            tiers["Free"].selected = false;
            tiers = tiers
        }

        // If Free is selected, select all (the keys are dynamic)
        if (tiers["Free"].selected) {
            console.log("Free is selected, selecting all")
            tiers = Object.keys(tiers)
                .reduce((acc, id) => ({ ...acc, [id]: { name: tiers[id].name, selected: true } }), {});
        }

        if (Object.keys(tiers).filter(tier => tiers[tier].selected).length === Object.keys(tiers).length) {
            selectedString = "Free + Paid";
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

    let onlyFree = false;

    function toggleOnlyFree() {
        if (onlyFree) {
            tiers = Object.keys(tiers)
                .reduce((acc, id) => ({ ...acc, [id]: { name: tiers[id].name, selected: true } }), {});
            onlyFree = false;
        } else {
            tiers = Object.keys(tiers)
                .reduce((acc, id) => ({ ...acc, [id]: { name: tiers[id].name, selected: false } }), {});
            tiers["Free"].selected = true;
            onlyFree = true;
        }
    }

    onMount(updateSelectedString);

    function addNewTier() {
        openModal(TiersModal);
    }
</script>

<div class="dropdown">
    <label tabindex="0" class="{$$props.buttonClass??"btn "}">
        {selectedString}
        <CaretDown class="ml-2" size={24} />
    </label>
    <ul tabindex="0" class="dropdown-content z-[1] menu p-2 bg-background rounded">
        {#each Object.keys(tiers) as tier}
            <li>
                <label class="w-full flex flex-row gap-4">
                    <input type="checkbox" class="checkbox" bind:checked={tiers[tier].selected} on:change={(e) => { updateSelectedString(tier); onlyFree = false; }} />
                    <span class="w-full"
                    >{tiers[tier].name}</span>

                    {#if tier === "Free"}
                        <button
                            class="text-xs text-foreground whitespace-nowrap ml-12"
                            class:button={!onlyFree}
                            class:button-black={!onlyFree}
                            on:click={toggleOnlyFree}
                        >
                            Only
                            {#if onlyFree}
                                non-subscribers will see this content
                            {/if}
                        </button>
                    {/if}
                </label>
            </li>
        {/each}
        <li class="border-t border-border">
            <button class="text-foreground w-full flex flex-row gap-4" on:click={addNewTier}>
                Add a new tier
            </button>
        </li>
    </ul>
</div>

<style lang="postcss">
    .dropdown .dropdown-content {
        @apply !bg-background/10  !backdrop-blur-[50px];
        @apply !outline-black p-4;
    }
</style>