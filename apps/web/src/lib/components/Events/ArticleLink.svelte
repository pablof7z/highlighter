<script lang="ts">
	import { getSummary } from "$utils/article";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import ItemLink from "./ItemLink.svelte";

    export let article: NDKArticle;
    export let grid = false;
    export let skipAuthor = false;

    const summary = article.summary || getSummary(article);
    const isFullVersion = !article.tagValue("full");
    const wordCount = article.content.split(" ").length;
    const readTime = Math.ceil(wordCount / 265);
</script>

<ItemLink
    event={article}
    {grid}
    {skipAuthor}
    image={article.image}
    title={article.title}
    description={summary}
    durationTag={isFullVersion ? `${readTime} min read` : undefined}
/>
