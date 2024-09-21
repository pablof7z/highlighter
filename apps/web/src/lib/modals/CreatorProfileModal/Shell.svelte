<script lang="ts">
    import ModalShell from "$components/ModalShell.svelte";
	import CommunityType from "./CommunityType.svelte";
	import { NavigationOption } from "../../../app";
	import Monetization from "./Monetization.svelte";
	import Pricing from "./Pricing.svelte";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import Start from "./Start.svelte";
	import { CaretLeft } from "phosphor-svelte";
	import Profile from "./Profile.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import currentUser from "$stores/currentUser";
	import { writable } from "svelte/store";
    import _createGroup from "$utils/groups/create.js";
	import { CreateState } from ".";
	import { NDKEvent, NDKKind, NDKList, NDKRelaySet, NDKSimpleGroup, NDKSubscription, NDKSubscriptionTier, NDKTag, NostrEvent } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { groupsList, tierList } from "$stores/session";
	import Create from "./Create.svelte";
	import { GroupData } from "$components/Groups";

    let title: string;
    let step = "start";
    // step = 'created';

    let nextStep: string;

    let actionButtons: NavigationOption[];
    let extraButtons: NavigationOption[] = [];
    let actionButtonsIndex = 0;
    $: {
        actionButtons = []

        if (step === 'create' || step === 'created' || step === 'failed') {
        } else {
            if (step !== 'start') {
                actionButtons.push({ name: "Back", icon: CaretLeft, iconProps: {  }, buttonProps: { variant: 'secondary' }, fn: back });
            }

            actionButtons.push({ name: "Next", buttonProps: { variant: 'default', class: 'px-10' }, fn: next });
            actionButtonsIndex = actionButtons.length - 1;
        }
        actionButtons = actionButtons;
    }
    
    let prevSteps: string[] = [];
    function back() {
        extraButtons = [];
        step = prevSteps.pop() ?? 'start';
    }

    function next() {
        extraButtons = [];
        prevSteps.push(step);
        step = nextStep;
    }

    let communityType: string;
    let monetizationType: string;

    const state = writable<CreateState>({});

    let created = false;
    $: if (!created && step === 'create') {
        created = true;

        create($state)
            .then(() => {
                step = 'created';
            })
            .catch((e) => {
                console.error(e);
                step = 'failed';
            });
    }

    let groupData: GroupData | undefined;

    async function createGroup(state: CreateState) {
        const randomNumber = Math.floor(Math.random() * 1000000);
        const groupId = 'group' + randomNumber;
        return await _createGroup(
            groupId,
            state.relays!,
            state.name,
            state.picture,
            state.about,

            // TODO: This should come from the relay
            [import.meta.env.VITE_CREATOR_RELAY_PUBKEY],
        )
    }

    async function createMonetization(state: CreateState, group: NDKSimpleGroup) {
        const tier = new NDKSubscriptionTier($ndk);
        tier.kind = NDKKind.SubscriptionTier;
        tier.title = "Members";
        tier.content = "Become a member of the "+state.name+" community.";
        for (const amount of state.amounts!) {
            tier.addAmount(amount.amount, amount.currency, amount.term);
        }
        tier.tags.push(["h", group.groupId, ...group.relayUrls()]);
        await tier.publish();
        tier.publish(group.relaySet);

        $tierList ??= new NDKList($ndk);
        $tierList.kind = NDKKind.TierList;

        $tierList.addItem([ "e", tier.id, group.relayUrls()[0]??"", group.groupId ])
        await $tierList.publishReplaceable();
    }

    async function setGroupState(group: NDKSimpleGroup, state: string) {
        const e = new NDKEvent($ndk, {
            kind: 9006,
            tags: [["h", group.groupId], [state]]
        } as NostrEvent);
        await e.publish(group.relaySet);
    }

    async function pinGroup(group: NDKSimpleGroup) {
        $groupsList ??= new NDKList($ndk);
        $groupsList.kind = NDKKind.SimpleGroupList;

        groupData = {
            id: group.groupId,
            relayUrls: group.relayUrls(),
        }

        $groupsList.addItem([ "group", group.groupId, ...group.relayUrls() ]);
        await $groupsList.publishReplaceable();

    }

    async function create(state: CreateState) {
        const group = await createGroup(state);
        
        if (state.monetization === 'subscription') {
            await createMonetization(state, group);
            await setGroupState(group, "closed");
        }

        await pinGroup(group);
    }
</script>

<ModalShell
    {title}
    containerClass="relative"
    class="max-w-md w-full max-sm:h-[90vh]"
    {actionButtons}
>
    <UserProfile user={$currentUser} let:userProfile>
        {#if step === "start"}
            <Start bind:title bind:buttonLabel={actionButtons[actionButtonsIndex].name} bind:nextStep {state} />
        {:else if step === "community-type"}
            <CommunityType bind:title bind:buttonLabel={actionButtons[actionButtonsIndex].name} bind:communityType bind:nextStep {state} />
        {:else if step === "monetization"}
            <Monetization bind:title bind:buttonLabel={actionButtons[actionButtonsIndex].name} bind:monetizationType bind:nextStep {state} />
        {:else if step === "pricing"}
            <Pricing bind:title bind:buttonLabel={actionButtons[actionButtonsIndex].name} bind:monetizationType bind:nextStep bind:extraButtons {state} />
        {:else if step === 'profile'}
            <Profile bind:title bind:buttonLabel={actionButtons[actionButtonsIndex].name} bind:nextStep bind:extraButtons {communityType} {userProfile} {state} />
        {:else if step === 'create' || step === 'created' || step === 'failed'}
            <Create bind:title {step} {groupData} />
        {/if}
    </UserProfile>

    <div slot="footerExtra">
        {#if step !== 'create' && step !== 'created' && step !== 'failed'}
            <HorizontalOptionsList options={extraButtons} />
        {/if}
    </div>
</ModalShell>