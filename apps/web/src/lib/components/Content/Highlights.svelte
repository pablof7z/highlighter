<script lang="ts">
	import StoreFeed from "$components/Feed/StoreFeed.svelte";
import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { kinds } from "nostr-tools";
	import { getContext, onDestroy } from "svelte";

    export let wrappedEvent = getContext("wrappedEvent") as NDKEvent;
    export let highlights = $ndk.storeSubscribe([
        {kinds: [ NDKKind.Highlight ], ...wrappedEvent.filter()}
    ])

    onDestroy(() => {
        highlights.unsubscribe();
    })
</script>

<StoreFeed
    feed={highlights}
    eventProps={{skipArticle: true}}
/>