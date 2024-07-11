<script lang="ts">
	import { Plus, X } from 'phosphor-svelte';
    import { Button } from "$components/ui/button";
	import TiersModal from "$modals/TiersModal.svelte";
	import { loadedGroup } from "$stores/item-view";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import { Block } from "konsta/svelte";
    import * as Tiers from "$components/Tiers/index.js";
	import { getContext } from "svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { NDKSubscriptionTier, NDKSimpleGroup, NDKKind } from "@nostr-dev-kit/ndk";
    import * as Tabs from "$components/ui/tabs";
    import * as Popover from "$lib/components/ui/popover";
    import * as Select from "$lib/components/ui/select";
	import Input from '$components/ui/input/input.svelte';
	import TierEditor from '$components/Creator/TierEditor.svelte';

    const group = getContext("group") as NDKSimpleGroup;

    function addMember() {
        const pubkey = prompt("Enter the pubkey of the member you want to add");
        if (pubkey) {
            const user = $ndk.getUser({pubkey})
            group.addUser(user);
        }
    }

    let currencies = [ "USD" ];
    let currency = "USD";

    let newCurrency = "";

    let tiers: NDKSubscriptionTier[] = [];

    function addTier() {
        const tier = new NDKSubscriptionTier($ndk);
        tiers = [...tiers, tier];
    }
    

    const possibleCurrencies = ["USD", "EUR", "sats"];
    let availablePossibleCurrencies: string[] = [];
    
    $: availablePossibleCurrencies = possibleCurrencies.filter(c => !currencies.includes(c));

    function addCurrency(c: string) {
        currencies = [...currencies, c ];
    }

    function removeCurrency(e: MouseEvent, c: string) {
        e.stopPropagation();
        currencies = currencies.filter(currency => currency !== c);
    }

    async function saveTiers() {
        for (const tier of tiers) {
            tier.tags.push(["h", group.groupId, ...group.relaySet.relayUrls]);
            tier.kind = NDKKind.SubscriptionTier;
            tier.publish(group.relaySet);
        }

    }
</script>

<Block>

    <h1>Pricing</h1>

    <!-- <div class="flex flex-row gap-2">
    <Tabs.Root bind:value={currency}>
        <Tabs.List>
            {#each currencies as c}
                <Tabs.Trigger value={c}>
                    {c}
                    <Button size="xs" variant="secondary" on:click={(e) => removeCurrency(e, c)}>
                        <X />
                    </Button>
                </Tabs.Trigger>
            {/each}

        </Tabs.List>
    </Tabs.Root>
        {#if availablePossibleCurrencies.length > 0}
            <Select.Root onSelectedChange={(e) => addCurrency(e.value)}>
                <Select.Trigger class="w-fit">
                    Add Currency
                </Select.Trigger>
                <Select.Content>
                    {#each availablePossibleCurrencies as c}
                        <Select.Item value={c}>{c}</Select.Item>
                    {/each}
                </Select.Content>
            </Select.Root>
        {/if}
    </div> -->

    <Tiers.Shell
        {group}
        let:tiers={existingTiers}
    >
        <ScrollArea orientation="horizontal">
            <div class="w-max flex flex-row gap-6">
                {#each existingTiers as tier}
                    <div class="w-96">
                        <TierEditor tier={tier} />
                    </div>
                {/each}
                {#each tiers as tier}
                    <div class="w-96">
                        <TierEditor tier={tier} />
                    </div>
                {/each}
                <!-- <Card.GroupTier {tier}>
                </Card.GroupTier> -->
            </div>
        </ScrollArea>
    </Tiers.Shell>


    <div class="flex flex-row justify-between">
        <Button on:click={addTier}>
            Add Membership Level
        </Button>

        <Button variant="accent" on:click={saveTiers}>
            Save Tiers
        </Button>
    </div>
    
    
    <h1>Members</h1>
    
    {#if $loadedGroup?.memberList}
        {#each $loadedGroup.memberList.members as member}
            <div>{member}</div>
        {/each}
    {/if}

    <Button on:click={addMember}>
        Add Member
    </Button>
</Block>