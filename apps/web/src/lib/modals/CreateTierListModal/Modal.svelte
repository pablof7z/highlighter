<script lang="ts">
    import RadioButton from "$components/Forms/RadioButton.svelte";
    import * as Card from "$components/ui/card";
	import { Button } from "$components/ui/button";
	import ModalShell from "$components/ModalShell.svelte";
	import { tierAmountToString } from "$lib/events/tiers";
	import currentUser from "$stores/currentUser";
	import { ndk } from "$stores/ndk";
	import { groupsList, tierList } from "$stores/session";
	import { closeModal } from "$utils/modal";
	import { NDKKind, NDKList, NDKRelaySet, NDKSimpleGroup, NDKSubscriptionAmount, NDKSubscriptionTier, NDKUserProfile } from "@nostr-dev-kit/ndk";
    import _createGroup from "$utils/groups/create.js";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { defaultRelays } from "$utils/const";
	import { Input } from "$components/ui/input";
	import { CaretDoubleRight, CaretRight } from "phosphor-svelte";

    export let tier: NDKSubscriptionTier;
    export let onSave: () => void;
    tier = new NDKSubscriptionTier($ndk);

    tier.title = "Subscribers";

    let selection: string;

    const presets: NDKSubscriptionAmount[][] = [
        [
            { amount: 200, currency: "USD", term: "monthly" },
            { amount: 2000, currency: "USD", term: "yearly" },
            { amount: 4000, currency: "sats", term: "monthly" }
        ], [
            { amount: 500, currency: "USD", term: "monthly" },
            { amount: 3000, currency: "USD", term: "yearly" },
            { amount: 5000, currency: "sats", term: "monthly" }
        ], [
            { amount: 1000, currency: "USD", term: "monthly" },
            { amount: 10000, currency: "USD", term: "yearly" },
            { amount: 10000, currency: "sats", term: "monthly" }
        ], [
            { amount: 2500, currency: "USD", term: "monthly" },
            { amount: 25000, currency: "USD", term: "yearly" },
            { amount: 50000, currency: "sats", term: "monthly" }
        ]
    ];

    async function createTiers(groupId: string, relays: string[]) {
        const selectedPreset = presets[parseInt(selection)];

        for (const priceLine of selectedPreset) {
            tier.addAmount(priceLine.amount, priceLine.currency, priceLine.term);
        }

        tier.tags.push(["h", groupId, ...relays])

        await tier.sign();
        tier.publish(relaySet);
        return [tier];
    }

    let groupId: string | undefined;

    

    async function createGroup() {
        const randomNumber = Math.floor(Math.random() * 1000000);
        groupId ??= $currentUser.pubkey + "-" + randomNumber;

        return await _createGroup(
            groupId,
            defaultRelays,
            name ?? "Community",
            picture ?? "",
            about ?? "",
            [import.meta.env.VITE_CREATOR_RELAY_PUBKEY]
        )
    }

    let userProfile: NDKUserProfile;
    let name: string | undefined, picture: string | undefined, about: string | undefined;
    $: if (userProfile) {
        const n = userProfile.displayName ?? userProfile.name
        if (n) name = `${n}'s Highlighter`
        picture = userProfile.image;
        about = userProfile.about;
    }

    const relaySet = NDKRelaySet.fromRelayUrls(['ws://localhost:2929'], $ndk);

    async function pinGroup(group: NDKSimpleGroup) {
        $groupsList ??= new NDKList($ndk);
        $groupsList.kind = NDKKind.SimpleGroupList;

        $groupsList.addItem([ "group", group.groupId, ...group.relayUrls() ]);
        await $groupsList.publishReplaceable(relaySet);
    }

    async function save() {
        const group = await createGroup();
        const tiers = await createTiers(group.groupId, group.relayUrls());

        $tierList ??= new NDKList($ndk);
        $tierList.kind = NDKKind.TierList;
        $tierList.alt = "This is a list of subscription tiers";
        $tierList.addItem(tier);

        for (const tier of tiers) {
            $tierList.addItem(tier);
        }

        await $tierList.sign();
        $tierList.publishReplaceable(relaySet);

        await pinGroup(group);

        onSave?.();
        
        closeModal();
    }

</script>

<UserProfile bind:userProfile user={$currentUser} />

<ModalShell
    closeOnOutsideClick={false}
    title="Going Paid"
    actionButtons={[
        { name: "Cancel", fn: closeModal, buttonProps: { variant: 'secondary' } },
        { name: "Save", fn: save, buttonProps: { variant: 'default', class: 'px-10' } }
    ]}
    class="!max-md w-full"
>
    <div class="flex flex-row p-2 border rounded-sm items-start text-foreground text-xs gap-2">
        <CaretDoubleRight class="text-gold" size={20} />
        <div class="flex flex-col items-start gap-1 grow">
            <span class="font-bold text-foreground text-sm">
                Let's create your paid publication
            </span>
            <div class="text-xs text-muted-foreground">
                This is where you'll be able to charge for access to some of your content.
            </div>
        </div>

    </div>

    <div class="flex flex-col items-start gap-1">
        <div class="text-semibold">Publication Name</div>
        <Input bind:value={name} />
    </div>

    <div class="grid grid-cols-2 gap-2">
        {#each presets as preset, i}
            <RadioButton color="gold" skipCheck bind:currentValue={selection} value={i.toString()}>
                {#each preset as amount, j}
                    {#if j === 0}
                        <div class="text-4xl font-bold">
                            {tierAmountToString(amount)}
                        </div>
                    {:else}
                        <div class="text-muted-foreground text-xs whitespace-nowrap">
                            {tierAmountToString(amount)}
                        </div>
                    {/if}
                {/each}
            </RadioButton>
        {/each}
        <!-- <RadioButton color="gold" skipCheck bind:currentValue={selection} value="custom" class="col-span-3">
            Custom

            {#if selection === "custom"}
                {#each amounts as amount, i}
                    <div class="w-full" in:slide>
                        <TierAmountLine
                            bind:amount={amount}
                            forceOpen={i === amounts.length - 1}
                            on:delete={() => {
                                amounts = amounts.filter((_, index) => index !== i);
                            }}
                        />
                    </div>
                {/each}
            {/if}
        </RadioButton> -->
    </div>

    <div class="text-xs text-muted-foreground w-full">
        Don't fret; you can change this later.
    </div>
</ModalShell>