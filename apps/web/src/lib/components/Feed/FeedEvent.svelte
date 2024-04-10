<script lang="ts">
	import NDK, { NDKArticle, NDKVideo, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import FeedArticle from "./FeedArticle.svelte";
	import FeedGroupPost from "./FeedGroupPost.svelte";
	import FeedVideo from "./FeedVideo.svelte";
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
	import Note from "./Note.svelte";

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
    <a class="w-full max-sm:max-w-[100vw] max-sm:overflow-hidden discussion-item">
        {#if event.kind === NDKKind.GroupNote || event.kind === NDKKind.Text}
            <Note {event} urlPrefix="/e/" />
        {:else if event.kind === NDKKind.Article}
            <ArticleLink article={NDKArticle.from(event)} {skipAuthor} />
        {:else if event.kind === NDKKind.HorizontalVideo}
            <VideoLink video={NDKVideo.from(event)} {skipAuthor} />
        {/if}
    </a>
{/if}