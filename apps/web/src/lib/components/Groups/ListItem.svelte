<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    import { Button } from "$lib/components/ui/button/index.js";
	import { onDestroy } from "svelte";
	import { Group } from ".";

    export let group: Group;
    export let selected: boolean;
    export let selectedTiers: NDKSubscriptionTier[];

    let groupTiers: Record<string, boolean> = {};

    const tiers = $ndk.storeSubscribe([
        {kinds: [NDKKind.SubscriptionTier], "#h": [group.groupId]}
    ], { relaySet: group.relaySet, onEose: updateGroupTiers }, NDKSubscriptionTier);

    onDestroy(() => {
        tiers.unsubscribe();
    })

    function updateGroupTiers() {
        groupTiers = {};
        for (const tier of $tiers) {
            groupTiers[tier.dTag] = true;
        }
    }

    let buttonLabel: string | undefined;

    $: if (scope === 'private') {
        if (!selected) {
            selectedTiers = [];
        } else {
            selectedTiers = $tiers.filter(tier => groupTiers[tier.dTag!]);
            if (selectedTiers.length === 0) { buttonLabel = "Select Tiers"; }
            else if (selectedTiers.length === $tiers.length) { buttonLabel = "All Members"; }
            else if (selectedTiers.length === 1) { buttonLabel = selectedTiers[0].title }
            else { buttonLabel = `${selectedTiers.length} Tiers`; }
        }
    }

    let showTiers: boolean;
    $: showTiers = scope === 'private' && $tiers.length > 1;

</script>

{#if scope === "public" || $tiers.length > 0}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <Checkbox bind:value={selected} class="p-3">
        <div class="flex flex-row gap-4 items-center">
            <img src={group.picture} alt={group.name} class="w-8 h-8 object-cover rounded-full" />

            <div class="flex flex-col items-start">
                <b>{group.name}</b>
                <span class="text-xs text-muted-foreground">

                </span>
            </div>
        </div>

        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <div slot="button" class:hidden={!showTiers} on:click|stopPropagation>
            {#if selected && $tiers.length > 0}
                <DropdownMenu.Root>
                    <DropdownMenu.Trigger asChild let:builder>
                        <Button variant="outline" builders={[builder]}>
                            {buttonLabel}
                        </Button>
                    </DropdownMenu.Trigger>
                    <DropdownMenu.Content class="w-56">
                        {#each $tiers as tier}
                            <DropdownMenu.CheckboxItem bind:checked={groupTiers[tier.dTag]}>
                                {tier.title}
                            </DropdownMenu.CheckboxItem>
                        {/each}
                    </DropdownMenu.Content>
                </DropdownMenu.Root>
            {/if}
        </div>
    </Checkbox>
{/if}