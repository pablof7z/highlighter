<script lang="ts">
    import { NDKArticle, NDKEvent, NDKHighlight, NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";
    import * as Card from '$components/Card';

    export let highlight: NDKHighlight;
    export let tag: NDKTag;

    let event: NDKEvent | NDKArticle | string | undefined;

    highlight.getArticle().then((a) => {
        event = a;
    });
</script>

{#if event instanceof NDKArticle}
    <Card.Article article={event} />
{:else if event instanceof NDKVideo}
    <Card.Video video={event} />
{:else if typeof event === 'string'}
    <Card.Url url={event} />
{/if}