<script lang="ts">
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import ArticleSummary from "./ArticleSummary.svelte";
	import ArticleCover from "./ArticleCover.svelte";
	import TagInput from "./TagInput.svelte";

    export let article: NDKArticle;

    let modified = Math.random();

    $: if (article.summary) {
        modified = Math.random();
    }
</script>

<border class="w-full h-full flex flex-col gap-6">
    <!-- {#key modified}
        <ArticleLink {article} skipLink={true} skipAuthor={true} />
    {/key} -->

    <ArticleCover bind:article />

    <section class="settings">
        <ArticleSummary bind:article />

        <TagInput event={article} />
    </section>
</border>
