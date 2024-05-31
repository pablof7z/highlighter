<script lang="ts">
    import EventWrapper from "$components/Feed/EventWrapper.svelte";
    import { NDKHighlight, NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import HighlightBody from "./HighlightBody.svelte";

    export let highlight: NDKHighlight;
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;
    export let skipArticle: boolean = false;
    export let expandReplies = false;
    export let showReply = false;
    export let scrollIntoView = false;
    export let compact = false;
    export let skipFooter = false;
    export let disableSwipe = false;
</script>
<EventWrapper
    topLevel={false}
    {showReply}
    event={highlight}
    placeholder="Add your thoughts about this highlight..."
    {expandReplies}
    {compact}
    {skipFooter}
    {disableSwipe}
    class={$$props.class}
    on:publish={() => {
        showReply = false;
        highlight.publish();
    }}
>
    <HighlightBody
        {highlight}
        {highlightedArticle}
        {skipArticle}
        skipHighlighter={true}
        {scrollIntoView}
        class="p-4 bg-white/10 rounded-box"
        contentClass="overflow-clip sm:overflow-auto scrollbar-hide"
    />
</EventWrapper>
