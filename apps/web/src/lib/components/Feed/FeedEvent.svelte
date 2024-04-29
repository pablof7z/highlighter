<script lang="ts">
	import NDK, { NDKArticle, NDKVideo, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import ArticleLink from "$components/Events/ArticleLink.svelte";
	import VideoLink from "$components/Events/VideoLink.svelte";
	import EventWrapper from "./EventWrapper.svelte";

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
    <div class="w-full max-sm:max-w-[100vw] max-sm:overflow-hidden discussion-item">
        {#if event.kind === NDKKind.GroupNote || event.kind === NDKKind.Text}
            <EventWrapper {event} />
        {:else if event.kind === NDKKind.Article}
            <ArticleLink article={NDKArticle.from(event)} {skipAuthor} />
        {:else if event.kind === NDKKind.HorizontalVideo}
            <VideoLink video={NDKVideo.from(event)} {skipAuthor} />
        {/if}
    </div>
{/if}