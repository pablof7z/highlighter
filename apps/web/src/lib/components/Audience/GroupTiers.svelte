<script lang="ts">
    import * as Audience from "$components/Audience";
	import Checkbox from "$components/Forms/Checkbox.svelte";
    import * as Groups from "$components/Groups";
    import { get, Writable } from "svelte/store";
    import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
	import { Button } from "$components/ui/button";

    export let group: Writable<Groups.GroupData>;
    export let state: Writable<Audience.State>;

    let value: boolean;
    value = !!($state.groups && $state.groups.find(g => g.id === $group.id))

    let selectedTiers: Audience.GroupTierEntry[];

    if ($state.tiers) selectedTiers = $state.tiers;
    else if ($group.tiers) {
        selectedTiers = $group.tiers.map(tier => { return {
            tierId: tier.dTag!,
            groupId: $group.id,
            relayUrls: $group.relayUrls
        }})
    }

    function toggled(e) {
        value = e.detail.value;
        state.update($state => {
            $state.groups ??= [];
            // $state.tiers 

            if (value) {
                $state.groups?.push($group)
                $state
            } else {
                $state.groups = $state.groups?.filter(g => g.id !== $group.id)
            }

            return $state;
        })
    }

    function tiersClicked(e) {
        e.preventDefault();
        e.stopPropagation();
    }
</script>

<Checkbox
    bind:value
    on:change={toggled}
>
    {$group.name}

    <svelte:fragment slot="button">
        {#if $group.tiers}
            <DropdownMenu.Root>
                <DropdownMenu.Trigger asChild let:builder>
                <Button builders={[builder]} variant="outline" on:click={tiersClicked}>
                    Tiers
                </Button>
            </DropdownMenu.Trigger>

            <DropdownMenu.Content class="absolute z-[999999]">
                <DropdownMenu.Group>
                    {#each $group.tiers as tier}
                        <DropdownMenu.CheckboxItem>
                            {tier.title}
                        </DropdownMenu.CheckboxItem>
                    {/each}
                </DropdownMenu.Group>
            </DropdownMenu.Content>
            </DropdownMenu.Root>
        {/if}
    </svelte:fragment>
</Checkbox>