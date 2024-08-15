<script lang="ts">
	import { NDKKind, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSubscriptionStart } from "@nostr-dev-kit/ndk";
    import * as Card from "$components/ui/card";
	import { ndk } from "$stores/ndk";
	import SubscriptionStartEvent from "./SubscriptionStartEvent.svelte";
    import { getContext } from "svelte";
	import { derived, Readable } from "svelte/store";
    import * as Groups from "$components/Groups";

    export let group: Readable<Groups.Group>;

    const events = $ndk.storeSubscribe([
        { kinds: [NDKKind.Subscribe], "#h": [$group.id] },
    ], undefined, NDKSubscriptionStart)

    const eventsFromNonMembers = derived([events, group], ([$events, group]) => {
        if (!$group.members) return $events;
        return $events.filter(e => !$group.members?.hasMember(e.pubkey));
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