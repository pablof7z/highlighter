<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKFilter, NDKKind, NDKRelaySet, NDKSimpleGroup, NDKSubscriptionTier } from "@nostr-dev-kit/ndk";

    export let group: NDKSimpleGroup | undefined = undefined;
    export let filter: NDKFilter | undefined = undefined;
    export let relaySet: NDKRelaySet | undefined = undefined;

    if (!filter && group?.groupId) {
        filter = { "#h": [group.groupId] }
        relaySet ??= group.relaySet;
    }

    const tiers = $ndk.storeSubscribe(
        { kinds: [NDKKind.SubscriptionTier], ...filter },
        { relaySet },
        NDKSubscriptionTier
    )
</script>

{JSON.stringify(filter)}
{group?.groupId}

<slot tiers={$tiers} />
