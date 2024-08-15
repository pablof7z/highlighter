<script lang="ts">
	import { Plus, X, CaretDown } from 'phosphor-svelte';
    import { Button } from "$components/ui/button";
	import { ndk } from "$stores/ndk";
	import { getContext } from "svelte";
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
	import { NDKSubscriptionTier, NDKSimpleGroup, NDKKind, NDKEvent, NDKSimpleGroupMetadata, NDKSimpleGroupMemberList } from "@nostr-dev-kit/ndk";
    import * as Collapsible from "$lib/components/ui/collapsible";
    import * as Groups from "$components/Groups";

	import TierEditor from '$components/Creator/TierEditor.svelte';
	import { Readable } from 'svelte/store';
	import EditMetadata from '../EditMetadata.svelte';
	import { layout } from '$stores/layout';
	import JoinRequests from './JoinRequests.svelte';

    export let group = getContext("group") as Readable<Groups.Group>;

    $layout.fullWidth = false;
    $layout.sidebar = false;

    function addMember() {
        const pubkey = prompt("Enter the pubkey of the member you want to add");
        if (pubkey) {
            const user = $ndk.getUser({pubkey})
            group.addUser(user).then(async (e) => {
                await e.publish(group.relaySet)

                const e2 = new NDKEvent($ndk);
                e2.kind = 9003;
                e2.tags.push(["h", group.groupId]);
                e2.tags.push(["p", pubkey]);
                e2.tags.push(["permission", "add-user"]);
                e2.tags.push(["permission", "remove-user"]);
                e2.publish(group.relaySet);
            });
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
        for (const tier of $group.tiers) {
            tier.publishReplaceable(group.relaySet);
        }
        
        for (const tier of tiers) {
            tier.tags.push(["h", group.groupId, ...group.relaySet.relayUrls]);
            tier.kind = NDKKind.SubscriptionTier;
            tier.publishReplaceable(group.relaySet);
        }

        if ($group.tiers.length + tiers.length > 0) {
            const e = new NDKEvent($ndk)
            e.kind = 9006;
            e.tags.push(["h", group.groupId ]);
            e.tags.push(["closed"]);
            e.publish(group.relaySet);

            const creatorRelayPubkey = import.meta.env.VITE_CREATOR_RELAY_PUBKEY;
            if (creatorRelayPubkey) {
                let event = new NDKEvent($ndk);
                event.kind = NDKKind.GroupAdminAddUser;
                event.tags.push(["h", group.groupId]);
                event.tags.push(["p", creatorRelayPubkey]);
                await event.publish(group.relaySet);

                event.kind = 9003;
                event.tags.push(["h", group.groupId]);
                event.tags.push(["p", creatorRelayPubkey]);
                event.tags.push(["permission", "add-user"]);
                event.tags.push(["permission", "remove-user"]);
                await event.publish(group.relaySet);
            }
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
    <Collapsible.Content class="flex flex-col gap-6">
        <EditMetadata {group} bind:forceSave={saveMetadata} />
        <Button class="w-fit" on:click={() => saveMetadata = true}>
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
                    <!-- {#if $group.tiers}
                        {#each $group.tiers as tier}
                            <div class="w-96">
                                <TierEditor tier={tier} />
                            </div>
                        {/each}
                    {/if}
                -->{#each tiers as tier}
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

    
    <JoinRequests {group} />
    
    
    <h1>Members</h1>
    
    {#if $group.members}
        {#each $group.members.members as member}
            <div>{member}</div>
        {/each}
    {/if}

    <Button on:click={addMember}>
        Add Member
    </Button>