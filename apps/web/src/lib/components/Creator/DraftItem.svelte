<script lang="ts">
	import ArticleView from './../../../routes/(app)/[id]/[tagId]/ArticleView.svelte';
	import type { DraftItem } from "$stores/drafts";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";

    export let item: DraftItem;

    // find most recent manually saved checkpoint
    const checkpoints = JSON.parse(item.checkpoints) as DraftItem["checkpoints"];
    let checkpoint = checkpoints[0];

    const payload = checkpoint.data;

    let article: NDKArticle;

    switch (item.type) {
        case "article":
            article = new NDKArticle($ndk, JSON.parse(payload.article));
            article.pubkey = $user.pubkey;
            break;
    }
</script>

{#if item.type === "article"}
    <ArticleView
        article={article}
        editUrl="/articles/new?draft={item.id}"
    />
{/if}