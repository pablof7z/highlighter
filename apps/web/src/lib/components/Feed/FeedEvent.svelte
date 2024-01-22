<script lang="ts">
	import NDK, { NDKArticle, NDKVideo, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import FeedArticle from "./FeedArticle.svelte";
	import FeedGroupPost from "./FeedGroupPost.svelte";
	import FeedVideo from "./FeedVideo.svelte";

    export let event: NDKEvent;
    export let skipAuthor = false;

    const supportedKinds = [
        NDKKind.GroupNote,
        NDKKind.Text,
        NDKKind.Article,
        NDKKind.HorizontalVideo,
    ];
</script>

{#if supportedKinds.includes(event.kind)}
    <div class="w-full max-sm:max-w-[100vw] max-sm:overflow-hidden">
        {#if event.kind === NDKKind.GroupNote || event.kind === NDKKind.Text}
            <FeedGroupPost {event} class="!py-10" />
        {:else if event.kind === NDKKind.Article}
            <FeedArticle article={NDKArticle.from(event)} {skipAuthor} />
        {:else if event.kind === NDKKind.HorizontalVideo}
            <FeedVideo video={NDKVideo.from(event)} />
        {/if}
    </div>
{/if}