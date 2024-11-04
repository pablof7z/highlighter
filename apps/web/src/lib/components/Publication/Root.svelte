<script lang="ts">
	import { get, writable } from "svelte/store";
    import { CreateState } from "./index.js";
	import createGroup from "$utils/groups/create.js";
	import { creatorRelayPubkey, defaultRelays } from "$utils/const.js";
	import currentUser from "$stores/currentUser.js";
	import { NDKEvent, NDKKind, NDKList, NDKSimpleGroup, NDKSubscriptionTier, NostrEvent } from "@nostr-dev-kit/ndk";
	import {pinGroup} from "$utils/groups/pin-group.js";
	import { ndk } from "$stores/ndk.js";
	import { tierList } from "$stores/session.js";

    export let state = writable<CreateState>();
    export let create = async function create(state: CreateState) {
        // randomg 16 char group id
        const groupId = Math.random().toString(36).substring(2, 18);
        const $user = get(currentUser);
        if (!$user) throw new Error("No user found");
        const group = await createGroup(
            groupId,
            state.relays ?? defaultRelays,
            state.name ?? "Untitled",
            state.picture ?? "",
            state.about ?? "",
            [$user.pubkey, creatorRelayPubkey]
        );
        
        if (state.monetization === 'subscription') {
            await createMonetization(state, group);
            await setGroupState(group, "closed");
        }

        await pinGroup(group);
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
</script>

<slot {state} {create} />