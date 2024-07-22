<script lang="ts">
	import { Plus, X, CaretDown } from 'phosphor-svelte';
    import { Button } from "$components/ui/button";
	import TiersModal from "$modals/TiersModal.svelte";
	import { loadedGroup } from "$stores/item-view";
	import { ndk } from "$stores/ndk";
	import { openModal } from "$utils/modal";
	import { Block } from "konsta/svelte";
    import * as Tiers from "$components/Tiers/index.js";
	import { getContext } from "svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { NDKSubscriptionTier, NDKSimpleGroup, NDKKind, NDKEvent, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";
    import * as Tabs from "$components/ui/tabs";
    import * as Popover from "$lib/components/ui/popover";
    import * as Select from "$lib/components/ui/select";
	import Input from '$components/ui/input/input.svelte';
    import * as Collapsible from "$lib/components/ui/collapsible";

	import TierEditor from '$components/Creator/TierEditor.svelte';
	import { Readable } from 'svelte/store';
	import EditMetadata from './EditMetadata.svelte';

    const group = getContext("group") as NDKSimpleGroup;
    const groupMetadata = getContext("groupMetadata") as Readable<NDKSimpleGroupMetadata>;
    const existingTiers = getContext("groupTiers") as Readable<NDKSubscriptionTier[]>;

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
        console.log(group.relaySet)
        console.log(tiers);
        console.log($existingTiers);
        for (const tier of $existingTiers) {
            tier.publishReplaceable(group.relaySet);
        }
        
        for (const tier of tiers) {
            tier.tags.push(["h", group.groupId, ...group.relaySet.relayUrls]);
            tier.kind = NDKKind.SubscriptionTier;
            tier.publishReplaceable(group.relaySet);
        }

        if ($existingTiers.length + tiers.length > 0) {
            const e = new NDKEvent($ndk)
            e.kind = 9006;
            e.tags.push(["h", group.groupId ]);
            e.tags.push(["closed"]);
            e.publish(group.relaySet);
        }
    }

    let saveMetadata = false;
</script>

<Collapsible.Root>
    <Collapsible.Trigger asChild let:builder>
        <Button builders={[builder]} variant="outline" class="w-full justify-between text-lg">
            Community Profile
            <CaretDown class="h-4 w-4" />
            <span class="sr-only">Toggle</span>
        </Button>
        </Collapsible.Trigger>
    <Collapsible.Content>
        <EditMetadata {group} bind:forceSave={saveMetadata} />
        <Button on:click={() => saveMetadata = true}>
            Save
        </Button>
    </Collapsible.Content>
</Collapsible.Root>

    <Collapsible.Root>
        <Collapsible.Trigger asChild let:builder>
            <Button builders={[builder]} variant="outline" class="w-full justify-between text-lg">
                Pricing
              <CaretDown class="h-4 w-4" />
              <span class="sr-only">Toggle</span>
            </Button>
          </Collapsible.Trigger>
        <Collapsible.Content>

            <ScrollArea orientation="horizontal">
                <div class="w-max flex flex-row gap-6">
                    {#each $existingTiers as tier}
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
    
        <div class="flex flex-row justify-between">
            <Button on:click={addTier}>
                Add Membership Level
            </Button>
    
            <Button variant="accent" on:click={saveTiers}>
                Save Tiers
            </Button>
        </div>
        
        </Collapsible.Content>
    </Collapsible.Root>

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

        
    
    
    <h1>Members</h1>
    
    {#if $loadedGroup?.memberList}
        {#each $loadedGroup.memberList.members as member}
            <div>{member}</div>
        {/each}
    {/if}

    <Button on:click={addMember}>
        Add Member
    </Button>