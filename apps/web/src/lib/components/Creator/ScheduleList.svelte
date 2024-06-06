<script lang="ts">
	import Box from "$components/PageElements/Box.svelte";
    import { ndk } from "$stores/ndk.js";
    import currentUser from "$stores/currentUser.js";
	import { NDKKind } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";

    const scheduleInfo = $ndk.storeSubscribe([
        { kinds: [NDKKind.DVMEventSchedule], authors: [$currentUser.pubkey]}
    ], { subId: 'schedules'})

    onDestroy(() => {
        scheduleInfo.unsubscribe();
    })
</script>

<Box title="Scheduled Posts">
    {$scheduleInfo?.length} schedule events
</Box>