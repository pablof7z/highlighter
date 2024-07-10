<script lang="ts">
	import { NDKArticle, NDKEvent, NDKWiki, NDKVideo } from '@nostr-dev-kit/ndk';
    import { getContext } from 'svelte';
    import ArticleBody from "./Article/Body.svelte";
    import VideoBody from "./Video/Body.svelte";
    import ModularArticleBody from "./ModularArticle/Body.svelte";
    import ModularArticleItem from "./ModularArticle/Item.svelte";
	import EventWrapper from '$components/Feed/EventWrapper.svelte';

    const wrappedEvent = getContext('wrappedEvent') as NDKEvent | NDKArticle | NDKVideo;
</script>

<div>
    {#if wrappedEvent.kind === 30040}
        <ModularArticleBody event={wrappedEvent} />
    {:else if wrappedEvent.kind === 30041}
        <ModularArticleItem article={wrappedEvent} />
    {:else if (wrappedEvent instanceof NDKArticle) || (wrappedEvent instanceof NDKWiki)}
        <ArticleBody
            article={wrappedEvent}
        />
    {:else if wrappedEvent instanceof NDKVideo}
        <VideoBody video={wrappedEvent} />
    {:else}
        <EventWrapper event={wrappedEvent} />
        <!-- <Event.Body event={wrappedEvent} /> -->
    {/if}
</div>