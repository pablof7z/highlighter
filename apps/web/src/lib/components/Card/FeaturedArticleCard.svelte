<script lang="ts">
	import { NDKArticle, NDKHighlight, type NDKTag, type NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { ndk } from "$stores/ndk.js";
	import { urlFromEvent, urlSuffixFromEvent } from "$utils/url";
	import FeaturedContentCard from "./FeaturedContentCard.svelte";
	import { getSummary } from "$utils/article";

    export let article: NDKArticle | undefined = undefined;
    export let tag: NDKTag | undefined = undefined;
    export let highlights: NDKHighlight[] = [];

    let url: string;
    let authorUrl: string;
    
    if (!article && tag)
        $ndk.fetchEvent(tag[1]).then(event => {
            if (event) {
                article = NDKArticle.from(event);
            }
        });

    $: if (article) {
        const suffix = urlSuffixFromEvent(article);
        if (authorUrl && suffix.length > 0)
            url = [authorUrl, suffix].join('/')
        else
            url = `a/${article.encode()}`
    }
</script>

{#if article}
    <FeaturedContentCard
        event={article}
        title={article.title??"Untitled"}
        image={article.image}
        description={getSummary(article, true)}
        author={article.author}
        href={urlFromEvent(article)}
        {highlights}
        {...$$props}
    />
{/if}