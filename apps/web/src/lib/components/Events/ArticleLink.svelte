<script lang="ts">
	import { getSummary } from "$utils/article";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import ItemLink from "./ItemLink.svelte";

    export let article: NDKArticle;
    export let grid = false;
    export let skipAuthor = false;
    export let size: "small" | "normal" | undefined = undefined;
    export let href: string | undefined = undefined;

    const summary = article.summary || getSummary(article);
    const isFullVersion = true;!article.tagValue("full");
    const wordCount = article.content.split(" ").length;
    const readTime = Math.ceil(wordCount / 265);
</script>

<ItemLink
    event={article}
    {size}
    {href}
    {grid}
    {skipAuthor}
    image={article.image}
    title={article.title}
    description={summary}
    durationTag={isFullVersion ? `${readTime} min read` : undefined}
    class={$$props.class??""}
/>