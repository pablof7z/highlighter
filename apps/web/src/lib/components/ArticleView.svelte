<script lang="ts">
	import { goto } from "$app/navigation";
	import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "@kind0/ui-common";
	import { type NDKArticle, NDKKind, type NDKEventId } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import ArticleRender from './ArticleRender.svelte';
	import ItemHeader from "$components/ItemHeader.svelte";

    export let article: NDKArticle;
    const author = article.author;
    export let editUrl: string | undefined = undefined;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let fillInSummary = true;

    const highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], ...article.filter() },
        { subId: 'article-highlights' }
    )

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
        highlights?.unsubscribe();
    });

    // Check if this user has access to the full article and if they do, redirect them to the full article
    const fullTiers = article.getMatchingTags("tier").map(t => t[1]);

    $: if ($userActiveSubscriptions.get(article.pubkey) && fullTiers.includes($userActiveSubscriptions.get(article.pubkey)!)) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        goto(`/${author.npub}/${dTag}`);
    }

    editUrl ??= `/articles/${article.tagValue("d")}/edit`;
</script>

<svelte:head>
    <title>{article.title}</title>
</svelte:head>

<div class="flex flex-col gap-2 px-4">
    <ItemHeader item={article} {editUrl} />
    <ArticleRender {article} {isFullVersion} {isPreview} {fillInSummary} />
</div>
