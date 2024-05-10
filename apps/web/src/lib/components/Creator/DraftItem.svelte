<script lang="ts">
	import type { ArticleCheckpoint, DraftCheckpoint, DraftItem } from "$stores/drafts";
	import { ndk, user } from "@kind0/ui-common";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import ArticleLink from '$components/Events/ArticleLink.svelte';
    import ThreadItem from "$components/Drafts/Items/Thread.svelte";

    export let item: DraftItem;

    // find most recent manually saved checkpoint
    const checkpoints = JSON.parse(item.checkpoints) as DraftCheckpoint[];
    let checkpoint = checkpoints[0];

    const payload = checkpoint.data;

    let article: NDKArticle;

    switch (item.type) {
        case "article":
            article = new NDKArticle($ndk, JSON.parse((payload as ArticleCheckpoint).event));
            article.pubkey = $user.pubkey;
            break;
    }
</script>

{#if item.type === "article"}
    <ArticleLink
        article={article}
        size="small"
        grid={true}
        href="/drafts/{item.id}"
    />
{:else if item.type === "thread"}
    <ThreadItem href="/drafts/{item.id}" {checkpoint} />
{/if}