<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKFilter, NDKRelaySet, NDKSubscriptionOptions } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";

    type EventWithFrom = typeof NDKEvent & { from: (event: NDKEvent) => NDKEvent };
    
    export let filters: NDKFilter[];
    export let opts: NDKSubscriptionOptions;
    export let type: EventWithFrom | undefined;

    const sub = $ndk.storeSubscribe(filters, opts, type);
    let filteredStore = sub;

    onDestroy(() => {
        sub?.unsubscribe();
    });
</script>

<slot
    store={filteredStore}
/>