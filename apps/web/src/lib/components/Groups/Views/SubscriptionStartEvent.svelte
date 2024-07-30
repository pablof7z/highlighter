<script lang="ts">
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKSimpleGroupMemberList, NDKSubscriptionStart } from "@nostr-dev-kit/ndk";
    import * as Card from "$components/ui/card";
	import AvatarWithName from "$components/User/AvatarWithName.svelte";
	import { tierAmountToString } from "$lib/events/tiers";
	import RecentZaps from "$components/Events/Zaps/RecentZaps.svelte";
	import Button from "$components/ui/button/button.svelte";
	import { ndk } from "$stores/ndk";

    export let event: NDKSubscriptionStart;
    export let group: NDKSimpleGroup;

    let zapEvents: NDKEvent[] = [];

    function accept() {
        const e = new NDKEvent($ndk);
        e.kind = NDKKind.GroupAdminAddUser;
        e.tags = [
            [ "h", group.groupId ],
            [ "p", event.pubkey ],
        ]
        e.publish(group.relaySet);
    }
</script>

<Card.Root>
    <Card.Header>
        <Card.Title>
            <AvatarWithName pubkey={event.pubkey} size="small" />
        </Card.Title>
    </Card.Header>

    <Card.Content>
        {#if event.amount}
            {tierAmountToString(event.amount)}
        {/if}

        <RecentZaps {event} bind:zapEvents />

        <Button
            on:click={accept}
        >
            {#if zapEvents.length > 0}
                Accept
            {:else}
                Accept without payment
            {/if}
        </Button>
    </Card.Content>
</Card.Root>