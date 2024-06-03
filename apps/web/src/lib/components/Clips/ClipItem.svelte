<script lang="ts">
	import ArticleLink from "$components/Events/ArticleLink.svelte";
    import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "$stores/ndk.js";
    import { NDKHighlight, type NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let event: NDKEvent;
    export let highlight = NDKHighlight.from(event);
    export let highlightedArticle: NDKArticle | NDKEvent | string | undefined = undefined;

    highlight.getArticle().then(result => highlightedArticle = result);
</script>

<EventWrapper {event} class="border border-base-200 p-6 rounded-box {$$props.class??""}">
    {#if highlightedArticle instanceof NDKArticle}
        <ArticleLink article={highlightedArticle} skipAuthor={true} size="small" />
    {/if}

    <EventContent ndk={$ndk} event={event} class="prose highlight" />
</EventWrapper>