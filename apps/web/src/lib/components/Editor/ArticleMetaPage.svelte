<script lang="ts">
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import ArticleSummary from "./ArticleSummary.svelte";
	import ArticleCover from "./ArticleCover.svelte";
	import TagInput from "./TagInput.svelte";

    export let article: NDKArticle;
</script>

<border class="w-full h-full flex flex-col gap-6">
    <section class="settings">
        <ArticleCover bind:article />
    </section>

    <ArticleSummary bind:article />

    <TagInput event={article} />
</border>
