<script lang="ts">
	import EventWrapper from "$components/Feed/EventWrapper.svelte";
	import { ndk } from "@kind0/ui-common";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";

    export let article: NDKArticle;

    const summary = article.summary || article.content.slice(0, 100);
</script>

<EventWrapper event={article} class={$$props.class??""}>
    {#if article.image}
        <img src={article.image} alt={article.title} class="w-full h-96 object-cover rounded rounded-b-none object-top" />
    {:else}
        <div class="w-full h-96 bg-gradient-to-r from-base-300/80 to-base-300 border-none object-top" />
    {/if}

    <div class="flex flex-col gap-1 w-full">
        <div class="text-white text-lg">
            {article.title}
        </div>

        <EventContent ndk={$ndk} event={article} content={summary} />
    </div>
</EventWrapper>