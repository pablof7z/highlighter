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

<!-- <div class="flex flex-row items-center justify-between mb-4">
    <button>
        <Quotes class="w-12 h-12" />
        <span>Quote</span>
    </button>

    <button>
        <Repeat class="w-12 h-12" />
        <span>Share</span>
    </button>

    <button>
        <Lightning class="w-12 h-12" />
        <span>Zap</span>
    </button>
</div> -->

<EventWrapper
    topLevel={false}
    {showReply}
    event={highlight}
    placeholder="Add your thoughts about this highlight..."
    class="mb-4" {expandReplies}
    {compact}
    {skipFooter}
    {disableSwipe}
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
        contentClass="max-h-[20vh] overflow-clip sm:overflow-auto scrollbar-hide"
    />
</EventWrapper>

<!-- 
<div class="border border-base-300 p-4">
    <div class="px-4">
        <div class="flex flex-row justify-between items-center">
            <AvatarWithName user={$currentUser} avatarSize="small" />

            <div class="dropdown dropdown-end">
                <button tabindex="0" class="button button-black px-6 py-3 rounded-box bg-base-300">
                    <Quotes class="w-4 h-4" />
                    <span>Quote</span>
                </button>
                
                <ul tabindex="0" class="menu dropdown-content">
                    <li><button>
                        <Quotes class="w-6 h-6" />
                        <span>Quote</span>
                    </button>
                    </li>
                    <li>
                    </li>
                </ul>
            </div>
        </div>
        <ContentEditor
            bind:value={content}
            allowMarkdown={false}
            toolbar={false}
            placeholder="What are your thoughts?"
            class="-mx-4 min-h-[5rem]"
        />
    </div>
    <div class="pl-2">
        <HighlightBody {highlight} {highlightedArticle} {skipArticle} class="py-4" />
    </div>
</div>

<style lang="postcss">
    button {
        @apply flex flex-row items-center gap-2;
        @apply text-white/80 hover:text-white;
    }
</style> -->