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

<div class="flex flex-row justify-between items-center border-y border-border px-2 py-4 w-full">
    <h2 class="grow mb-0">Highlights</h2>
</div>

<StoreFeed
    feed={highlights}
    eventProps={{skipArticle: true, compact: true}}
/>