<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
import UserProfile from "$components/User/UserProfile.svelte";
import type { NDKSubscriptionReceipt } from "@nostr-dev-kit/ndk";

    export let receipt: NDKSubscriptionReceipt;
    const validPeriod = receipt.validPeriod!;
    const start = validPeriod.start;
    const end = validPeriod.end;
</script>

<EventWrapper event={receipt} reverse={true} skipActions={true}>
    Valid pass
    {receipt.content}
    {start.toLocaleDateString()} - {end.toLocaleDateString()}
</EventWrapper>
