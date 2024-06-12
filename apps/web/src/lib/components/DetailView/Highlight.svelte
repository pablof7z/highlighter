<script lang="ts">
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";
    import Highlight from "$components/Highlight.svelte";
	import HighlightBody from "$components/HighlightBody.svelte";
	import currentUser from "$stores/currentUser";
    import { NDKEvent, NDKHighlight, NDKKind } from "@nostr-dev-kit/ndk";

    export let highlight: NDKEvent;
    export let showReply: boolean = false;
    export let replyKind: number = NDKKind.Text;
</script>

{#key highlight.id}
{#if highlight.pubkey === $currentUser?.pubkey || highlight.id === ""}
    {#key highlight.content}
        <HighlightBody
            highlight={NDKHighlight.from(highlight)}
            skipHighlighter={true}
            scrollable={true}
            scrollIntoView={true}
            class="p-4 bg-white/10 rounded-none max-h-[20vh] overflow-auto scrollbar-hide"
        />
        <NewPost
            kind={replyKind}
            bind:showReply
            autofocus={true}
            placeholder="What are your thoughts?"
            collapsed={false}
            on:publish={() => {
                showReply = false;
                highlight.publish();
            }}
            on:cancel={() => {
                window.history.back();
            }}
        />
    {/key}
{:else}
    <Highlight
        highlight={NDKHighlight.from(highlight)}
        skipArticle={true}
        bind:showReply
        expandReplies={!showReply}
        on:cancel={() => { window.history.back(); }}
    />
{/if}
{/key}
<!-- 
{#key highlight.id}
    <Highlight
        highlight={NDKHighlight.from(highlight)}
        skipArticle={true}
        on:cancel={() => { window.history.back(); }}
    />
    {#if showReply}
        <NewPost
            kind={replyKind}
            {showReply}
            autofocus={true}
            placeholder="What are your thoughts?"
            collapsed={false}
            on:publish={() => { showReply = false; }}
        />
    {/if}
{/key}

<FilterFeed filters={[{ kinds: [1],  ...highlight.filter() }]} /> -->