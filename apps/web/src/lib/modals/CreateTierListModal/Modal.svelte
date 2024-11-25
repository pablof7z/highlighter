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
    import type { CreateState } from "$components/Publication";
    import * as Publication from "$components/Publication";
	import { Input } from "$components/ui/input";
	import { CaretDoubleRight, CaretRight } from "phosphor-svelte";
    import Option from "$lib/components/Publication/Pricing/Option.svelte";
	import { presets } from "$components/Publication/Pricing";
	import { get, writable } from "svelte/store";
	import { NavigationOption } from "../../../app";

    export let tier: NDKSubscriptionTier;
    export let onSave: () => void;
    tier = new NDKSubscriptionTier($ndk);

    let state = writable<CreateState>({
		monetization: 'v4v',
		name: undefined,
		about: undefined,
		picture: undefined
	});

    tier.title = "Subscribers";

    let selection: string;

    

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

    let actionButtons: NavigationOption[] = [];
    let title: string = "Going Paid";

    let step = 0;

    let create: (state: CreateState) => Promise<void>;

    $: switch (step) {
        case 0:
            title = "Going Paid";
            actionButtons = [
                { name: "Cancel", fn: closeModal, buttonProps: { variant: 'secondary' } },
                { name: "Next", fn: () => {step++}, buttonProps: { variant: 'default', class: 'px-10' } }
            ];
            break;
        case 1:
            title = "Publication Details";
            actionButtons = [
                { name: "Cancel", fn: closeModal, buttonProps: { variant: 'secondary' } },
                { name: "Next", fn: () => {step++}, buttonProps: { variant: 'default', class: 'px-10' } }
            ];
            break;
        case 2:
            title = "Set your pricing";
            state.update((s) => {
                console.log({s});
                s.monetization = 'subscription';
                return s;
            });
            actionButtons = [
                { name: "Cancel", fn: closeModal, buttonProps: { variant: 'link' } },
                { name: "Back", fn: () => {step--}, buttonProps: { variant: 'secondary' } },
                { name: "Create Publication", fn: async () => {
                    await create($state);
                    closeModal();
                }, buttonProps: { variant: 'default', class: 'px-10' } }
            ]
            break;
    }

</script>

<UserProfile bind:userProfile user={$currentUser} />

<ModalShell
    closeOnOutsideClick={false}
    {title}
    {actionButtons}
    class="!max-md w-full"
>
    <Publication.Root bind:state bind:create>
        {#if step === 0}
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
        {:else if step === 1}
            <div class="flex flex-col items-start gap-1">
                <Publication.Profile {state} />
            </div>
        {:else if step === 2}
            <div class="grid grid-cols-2 gap-2">
                <Publication.Pricing {state} />
            </div>

            <div class="text-xs text-muted-foreground w-full">
                Don't fret; you can change this later.
            </div>
        {/if}
    </Publication.Root>
</ModalShell>