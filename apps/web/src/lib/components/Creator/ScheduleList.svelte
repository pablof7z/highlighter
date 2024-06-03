<script lang="ts">
	import Box from "$components/PageElements/Box.svelte";
    import { ndk } from "$stores/ndk.js";
import currentUser from "$stores/currentUser.js";
	import { NDKKind } from "@nostr-dev-kit/ndk";

    const scheduleInfo = $ndk.storeSubscribe([
        { kinds: [NDKKind.DVMEventSchedule], authors: [$user.pubkey]}
    ], { subId: 'schedules'})
</script>

<Box title="Scheduled Posts">
    {$scheduleInfo?.length} schedule events
</Box>