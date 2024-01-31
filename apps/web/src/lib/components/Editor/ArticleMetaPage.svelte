<script lang="ts">
	import CategorySelector from "$components/Forms/CategorySelector.svelte";
	import type { NDKArticle } from "@nostr-dev-kit/ndk";
	import ArticleSummary from "./ArticleSummary.svelte";
	import ArticleCover from "./ArticleCover.svelte";

    export let article: NDKArticle;
</script>

<border class="w-full h-full flex flex-col gap-6">
    <section class="settings">
        <ArticleCover bind:article />
    </section>

    <section class="settings">
        <ArticleSummary bind:article />
    </section>

    <section class="settings">
        <div class="field">
            <div class="title">
                Categories
            </div>
            <CategorySelector />
        </div>
    </section>
</border>
