<script lang="ts">
	import { NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
    import ListItem from "./ListItem.svelte";
	import { PublishInTierStore, Scope } from "$components/Studio";

    export let groups: Record<string, NDKSimpleGroup>;
    export let selectedGroups: Record<string, boolean>;
    export let publishInTiers: PublishInTierStore;
    export let scope: Scope;

    const selectedTiers: Record<string, NDKSubscriptionTier[]> = {};

    $: {
        const tiers = new Map<string, NDKSubscriptionTier>();

        for (const groupId in selectedGroups) {
            if (selectedGroups[groupId]) {
                for (const tier of selectedTiers[groupId] || []) {
                    tiers.set(tier.dTag!, tier);
                }
            }
        }
        
        publishInTiers.set(tiers);
    }
</script>

{#each Object.entries(groups) as [id, group]}
    {#if group.name}
        <ListItem
            {group}
            {scope}
            bind:selected={selectedGroups[id]}
            bind:selectedTiers={selectedTiers[id]}
        />
    {/if}
{/each}