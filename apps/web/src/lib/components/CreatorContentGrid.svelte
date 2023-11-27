<script lang="ts">
	import { EventCard } from "@kind0/ui-common";
    import ArticleGrid from "$components/Events/ArticleGrid.svelte";
	import { NDKKind, type NDKEvent, NDKArticle } from "@nostr-dev-kit/ndk";
	import { derived, type Readable } from "svelte/store";

    export let content: Readable<NDKEvent[]>;

    let articles = derived(content, $content => {
        return $content
            .filter((event: NDKEvent) => event.kind === NDKKind.Article)
            .map((event: NDKEvent) => NDKArticle.from(event));
    })
</script>

<div class="justify-start items-start gap-8 grid sm:grid-cols-2 lg:grid-cols-3">
    {#each $articles as article (article.id)}
        <ArticleGrid {article} size="large" skipAuthor={true} />
    {/each}
</div>
