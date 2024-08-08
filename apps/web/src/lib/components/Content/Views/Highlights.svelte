<script lang="ts">
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKHighlight, NDKKind } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy } from "svelte";

    export let wrappedEvent = getContext("wrappedEvent") as NDKEvent;
    export let highlights = $ndk.storeSubscribe([
        {kinds: [ NDKKind.Highlight ], ...wrappedEvent.filter()}
    ], { subId: 'content-highlights' }, NDKHighlight)

    onDestroy(() => {
        highlights.unsubscribe();
    })
</script>

<StoreFeed
    feed={highlights}
    eventProps={{skipArticle: true, compact: true}}
/>