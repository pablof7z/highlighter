<script lang="ts">
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
import Highlight from "$components/Highlight.svelte";
    import { NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";

    export let highlight: NDKEvent;
</script>

<div class="max-w-3xl">
    <Highlight highlight={NDKHighlight.from(highlight)} />
</div>

<!-- <FilterFeed filters={[{ kinds: [1],  ...highlight.filter() }]} /> -->