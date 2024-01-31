<script lang="ts">
	import type { TierSelection } from "$lib/events/tiers";
	import { onMount } from "svelte";

    export let tiers: TierSelection;
    export let value = "";

    function updateSelectedString(changingTier?: string) {
        // If a tier is being changed, and it's being unchecked, uncheck Free
        console.log({changingTier, selected: tiers[changingTier]?.selected});
        if (
            changingTier &&
            changingTier !== "Free" && !tiers[changingTier].selected) {
            tiers["Free"].selected = false;
            tiers = tiers
        }

        // If Free is selected, select all (the keys are dynamic)
        // if (tiers["Free"].selected) {
        //     console.log("Free is selected, selecting all")
        //     tiers = Object.keys(tiers)
        //         .reduce((acc, id) => ({ ...acc, [id]: { name: tiers[id].name, selected: true } }), {});
        // }

        if (Object.keys(tiers).length === 1 && tiers["Free"].selected) {
            value = "Public";
        } else if (Object.keys(tiers).length > 1 && tiers["Free"].selected && Object.keys(tiers).filter(tier => tiers[tier].selected).length === 1) {
            value = "Only Non-Subscribers";
        }
        else if (Object.keys(tiers).filter(tier => tiers[tier].selected).length === Object.keys(tiers).length) {
            value = "Public";
        } else if (Object.keys(tiers).filter(tier => tiers[tier].selected).length === 0) {
            value = "Select";
        } else if (
            Object.keys(tiers).filter(tier => tiers[tier].selected).length === Object.keys(tiers).length - 1 &&
            !tiers["Free"].selected
        ) {
            value = "Subscribers";
        } else {
            value = Object.keys(tiers)
                .filter(tier => tiers[tier].selected)
                .map(tier => tiers[tier].name)
                .join(", ");
        }
    }

    onMount(updateSelectedString);

</script>

{value}