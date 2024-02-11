<script lang="ts">
	import TiersModal from '$modals/TiersModal.svelte';
    import { CaretDown } from "phosphor-svelte";
	import { slide } from "svelte/transition";
	import type { TierSelection } from "$lib/events/tiers";
    import { createEventDispatcher, onMount } from "svelte";
	import { openModal } from "svelte-modals";
	import TiersLabel from './TiersLabel.svelte';

    export let show = false;
    export let tiers: TierSelection;
    export let alwaysOpen = false;

    if (alwaysOpen) show = true;

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

<div class="w-full flex-col justify-start items-start gap-2 inline-flex {$$props.class??""}">
        {#if !alwaysOpen}
            <button on:click={() => show = !show} class="text-base px-4 py-3 font-medium w-full text-left flex flex-row items-center justify-between">
            <div class="flex flex-col items-start gap-0">
                {#key tiers}
                    <h1>
                        <TiersLabel {tiers} bind:value={selectedString} />
                    </h1>
                {/key}
                {#if selectedString === "Free"}
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
        </button>
        {/if}
        {#if show}
            <ul class="flex flex-col gap-2 justify-stretch w-full flex-nowrap" transition:slide>
                {#each Object.keys(tiers) as tier}
                    <li
                        class="
                            rounded-box px-4
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
                <li class="border-t border-base-300">
                    <button class="text-white w-full flex flex-row gap-4" on:click={addNewTier}>
                        Add a new tier
                    </button>
                </li>
            </ul>
        {/if}
</div>