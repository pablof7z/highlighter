<script lang="ts">
	import TiersModal from '$modals/TiersModal.svelte';
    import { CaretDown, Plus } from "phosphor-svelte";
	import type { TierSelection } from "$lib/events/tiers";
    import { createEventDispatcher, onMount } from "svelte";
	import { openModal } from '$utils/modal';
	import TiersLabel from './TiersLabel.svelte';

    export let show = false;
    export let tiers: TierSelection;
    export let alwaysOpen = false;

    if (alwaysOpen) show = true;

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
            tiers = Object.keys(tiers)
                .reduce((acc, id) => ({ ...acc, [id]: { name: tiers[id].name, selected: true } }), {});
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

    let selectedString: string;
</script>

<div class={$$props.class??""}>
    {#if !alwaysOpen}
        <div tabindex="0" role="button" class="text-base px-4 py-3 font-medium w-full text-left flex flex-row items-center justify-between dropdown-button">
            <div class="flex flex-col items-start gap-0">
                {#key tiers}
                    <TiersLabel {tiers} bind:value={selectedString} />
                {/key}
                {#if selectedString === "Public"}
                    {#if onlyFree}
                    <div class="font-light text-sm opacity-50">
                        Only non-subscribers will see this content
                    </div>
                    {:else}
                        <div class="font-light text-sm opacity-50">
                            Content will be publicly visible
                        </div>
                    {/if}
                {:else if selectedString !== "Free" && selectedString !== "Select"}
                    <div class="font-light text-sm opacity-50">
                        Subscribers need to be on one of these tiers to see this content
                    </div>
                {/if}
            </div>
            <CaretDown color="white"/>
        </div>
    {/if}
    <ul class="{$$props.containerClass??""}">
        {#each Object.keys(tiers) as tier}
            <li
                class="
                    px-4
                    { tiers[tier].selected ? 'bg-white/10' : 'bg-white/5' }
                    { tier === "Free" ? 'border-t border-base-300' : '' }
                "
            >
                <label class="w-full flex flex-row gap-4 py-3">
                    <input type="checkbox" class="checkbox" bind:checked={tiers[tier].selected} on:change={(e) => { updateSelectedString(tier); onlyFree = false; }} />
                    <span class="w-full"
                    >{tiers[tier].name}</span>

                    {#if tier === "Free"}
                        <button
                            class="text-xs whitespace-nowrap"
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
        <li class="mt-2">
            <button class="button button-black" on:click={addNewTier}>
                <Plus size={24} />
                Add a new tier
            </button>
        </li>
    </ul>
</div>

<style>
    .dropdown-open .dropdown-button {
        @apply border border-base-300;
    }
</style>