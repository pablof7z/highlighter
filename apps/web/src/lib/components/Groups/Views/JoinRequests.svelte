<script lang="ts">
	import { NDKKind, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSubscriptionStart } from "@nostr-dev-kit/ndk";
    import * as Card from "$components/ui/card";
	import { ndk } from "$stores/ndk";
	import Avatar from "$components/User/Avatar.svelte";
	import SubscriptionStartEvent from "./SubscriptionStartEvent.svelte";
    import { getContext } from "svelte";
	import { derived, Readable } from "svelte/store";

    export let group: NDKSimpleGroup;
    const groupMembers = getContext("groupMembers") as Readable<NDKSimpleGroupMemberList | undefined>;

    const events = $ndk.storeSubscribe([
        { kinds: [NDKKind.Subscribe], "#h": [group.groupId] },
    ], undefined, NDKSubscriptionStart)

    const eventsFromNonMembers = derived([events, groupMembers], ([$events, $groupMembers]) => {
        if (!$groupMembers) return $events;
        return $events.filter(e => !$groupMembers.hasMember(e.pubkey));
    });
</script>


<Card.Root>
    <Card.Header>
        <Card.Title>
            Join Requests
        </Card.Title>
    </Card.Header>

    <Card.Content>
        <div class="grid grid-cols-3 gap-2">
            {#each $eventsFromNonMembers as req (req.id)}
                <SubscriptionStartEvent event={req} {group} />
            {/each}
        </div>
    </Card.Content>
</Card.Root>