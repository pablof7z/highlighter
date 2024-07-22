<script lang="ts">
	import { NDKArticle, NDKEvent, NDKWiki, NDKVideo } from '@nostr-dev-kit/ndk';
    import { getContext } from 'svelte';
    import ArticleBody from "./Article/Body.svelte";
    import CurationBody from "./Curation/Body.svelte";
    import VideoBody from "./Video/Body.svelte";
    import NoteBody from "./Note/Body.svelte";
    import ModularArticleBody from "./ModularArticle/Body.svelte";
    import ModularArticleItem from "./ModularArticle/Item.svelte";
	import EventWrapper from '$components/Feed/EventWrapper.svelte';
	import { curationKinds } from '$utils/event';

    export let event: NDKEvent | NDKArticle | NDKVideo = getContext('wrappedEvent') as NDKEvent | NDKArticle | NDKVideo;
    export let isPreview = false;
</script>

<div>
    {#if event.kind === 30040}
        <ModularArticleBody event={event} />
    {:else if event.kind === 30041}
        <ModularArticleItem article={event} />
    {:else if (event instanceof NDKArticle) || (event instanceof NDKWiki)}
        <ArticleBody
            article={event}
            {isPreview}
        />
    {:else if event instanceof NDKVideo}
        <VideoBody video={event} />
    {:else if event.kind === 1}
        <NoteBody {event} />
        this
    {:else if curationKinds.includes(event.kind)}
        <CurationBody
            list={event}
        />
    {:else}
        <EventWrapper event={event} />
        <!-- <Event.Body event={wrappedEvent} /> -->
    {/if}
</div>