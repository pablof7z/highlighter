<script lang="ts">
	import Checkbox from "$components/Forms/Checkbox.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
    import { Button } from "$lib/components/ui/button/index.js";

    export let group: NDKSimpleGroup;
    export let selected: boolean;

    let groupTiers: Record<string, boolean> = {};
    
    const tiers = $ndk.storeSubscribe([
        {kinds: [NDKKind.SubscriptionTier], "#h": [group.groupId]}
    ], { relaySet: group.relaySet, onEose: updateGroupTiers }, NDKSubscriptionTier);

    function updateGroupTiers() {
        groupTiers = {};
        for (const tier of $tiers) {
            groupTiers[tier.dTag] = true;
        }
    }
</script>

{$tiers.length}

<!-- svelte-ignore a11y-click-events-have-key-events -->
<!-- svelte-ignore a11y-no-static-element-interactions -->
<Checkbox bind:value={selected} class="p-3">
    <div class="flex flex-row gap-4 items-center">
        <img src={group.picture} alt={group.name} class="w-8 h-8 object-cover rounded-full" />

        <div class="flex flex-col items-start">
            <b>{group.name}</b>
            <span class="text-xs text-muted-foreground">{group.relayUrls().join(', ')}</span>
        </div>
    </div>

    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <div slot="button" on:click|stopPropagation>
        {#if selected && $tiers.length > 0}
            <DropdownMenu.Root>
                <DropdownMenu.Trigger asChild let:builder>
                    <Button variant="outline" builders={[builder]}>
                        All Members
                    </Button>
                </DropdownMenu.Trigger>
                <DropdownMenu.Content class="w-56">
                    <DropdownMenu.Label>Member Tiers</DropdownMenu.Label>
                    <DropdownMenu.Separator />
                    {#each $tiers as tier}
                        {#if groupTiers[tier.dTag]}
                            <DropdownMenu.CheckboxItem bind:checked={groupTiers[tier.dTag]}>
                                {tier.title}
                            </DropdownMenu.CheckboxItem>
                        {/if}
                    {/each}
                </DropdownMenu.Content>
            </DropdownMenu.Root>
        {/if}
    </div>
</Checkbox>