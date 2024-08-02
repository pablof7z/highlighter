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
	import { CreateState } from ".";
	import { stringify } from "querystring";
	import { create } from "domain";
	import { NDKEvent, NDKKind, NDKList, NDKRelaySet, NDKSimpleGroup, NDKSubscription, NDKSubscriptionTier, NostrEvent } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk";
	import { toast } from "svelte-sonner";
	import { groupsList, tierList } from "$stores/session";

    let title: string;
    let step = "start";

    let nextStep: string;

    let actionButtons: NavigationOption[];
    let extraButtons: NavigationOption[] = [];
    actionButtons = [
        { name: "Back", icon: CaretLeft, iconProps: {  }, buttonProps: { variant: 'secondary' }, fn: back },
        { name: "Next", buttonProps: { variant: 'default', class: 'px-10' }, fn: next }
    ]
    
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

    async function createGroup(state: CreateState) {
        const relaySet = NDKRelaySet.fromRelayUrls(state.relays!, $ndk);
        const group = new NDKSimpleGroup($ndk, relaySet);
        const randomNumber = Math.floor(Math.random() * 1000000);
        group.groupId = 'group' + randomNumber;
        const published = await group.createGroup();
        if (!published) throw new Error("Failed to create group");

        await group.setMetadata({ name: state.name, picture: state.picture, about: state.about });

        // TODO: This should come from the relay
        const creatorRelayPubkey = import.meta.env.VITE_CREATOR_RELAY_PUBKEY;
        if (creatorRelayPubkey) {
            let event = new NDKEvent($ndk);
            event.kind = NDKKind.GroupAdminAddUser;
            event.tags.push(["h", group.groupId]);
            event.tags.push(["p", creatorRelayPubkey]);
            await event.publish(group.relaySet);

            event = new NDKEvent($ndk);
            event.kind = 9003;
            event.tags.push(["h", group.groupId]);
            event.tags.push(["p", creatorRelayPubkey]);
            event.tags.push(["permission", "add-user"]);
            event.tags.push(["permission", "remove-user"]);
            await event.publish(group.relaySet);
        }

        return group;
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

        $groupsList.addItem([ "group", group.groupId, ...group.relayUrls() ])
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
    class="max-w-md w-full"
    {actionButtons}
>
    <UserProfile user={$currentUser} let:userProfile>
        {#if step === "start"}
            <Start bind:title bind:buttonLabel={actionButtons[1].name} bind:nextStep {state} />
        {:else if step === "community-type"}
            <CommunityType bind:title bind:buttonLabel={actionButtons[1].name} bind:communityType bind:nextStep {state} />
        {:else if step === "monetization"}
            <Monetization bind:title bind:buttonLabel={actionButtons[1].name} bind:monetizationType bind:nextStep {state} />
        {:else if step === "pricing"}
            <Pricing bind:title bind:buttonLabel={actionButtons[1].name} bind:monetizationType bind:nextStep bind:extraButtons {state} />
        {:else if step === 'profile'}
            <Profile bind:title bind:buttonLabel={actionButtons[1].name} bind:nextStep bind:extraButtons {communityType} {userProfile} {state} />
        {:else if step === 'create'}
            <div class="p-4">
                Creating community...
            </div>
        {:else if step === 'created'}
            <div class="p-4">
                Community created!
            </div>
        {:else if step === 'failed'}
            <div class="p-4">
                Failed to create community
            </div>
        {/if}
    </UserProfile>

    <div slot="footerExtra">
        <HorizontalOptionsList options={extraButtons} />
    </div>
</ModalShell>