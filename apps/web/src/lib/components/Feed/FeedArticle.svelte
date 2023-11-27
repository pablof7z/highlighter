<script lang="ts">
	import FeedEvent from "$components/FeedEvent.svelte";
	import { ndk } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let article: NDKArticle;
    const dTag = article.tagValue("d")!;

    const summary = article.summary || article.content.slice(0, 100);
</script>

<FeedEvent event={article} suffixUrl={dTag}>
    {#if article.image}
        <img src={article.image} alt={article.title} class="w-full h-96 object-cover rounded-t-lg" />
    {/if}

    <div class="flex flex-col gap-1 w-full">
        <div class="text-white text-lg">
            {article.title}
        </div>

        <EventContent ndk={$ndk} event={article} content={summary} />
    </div>
</FeedEvent>