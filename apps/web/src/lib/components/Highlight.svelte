<script lang="ts">
    import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKHighlight, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import HighlightBody from "./HighlightBody.svelte";

    export let highlight: NDKHighlight;
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;
</script>

<EventWrapper event={highlight} reverse={true} class={$$props.class??""}>
    <div class="pl-12">
        <HighlightBody {highlight} {highlightedArticle} />
    </div>
</EventWrapper>
