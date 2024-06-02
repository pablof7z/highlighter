<script lang="ts">
	import { getSummary } from '$utils/article';
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "@kind0/ui-common";
	import { type NDKArticle, NDKTag, NDKKind, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import HighlightingArea from './HighlightingArea.svelte';
	import HighlightedContent from './HighlightedContent.svelte';
	import EventTags from './Events/EventTags.svelte';
	import currentUser from '$stores/currentUser';
	import { page } from '$app/stores';
	import ItemViewZaps from './Event/ItemView/ItemViewZaps.svelte';
	import { createBlossom } from '$utils/blossom.js';
	import UserProfile from './User/UserProfile.svelte';
	import { UserProfileType } from '../../app';
	import ArticleRenderShell from './Event/Article/ArticleRenderShell.svelte';

    export let article: NDKArticle;
    const author = article.author;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let fillInSummary = true;
    export let url = $page.url.pathname;

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

    $: if (fullTiers.includes($userActiveSubscriptions.get(article.pubkey))) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        // goto(`/${author.npub}/${dTag}`);
    }

    let highlightTags: NDKTag[] = article.referenceTags();

    const hTag = article.tagValue("h");
    if (hTag) highlightTags.push(["h", hTag]);

    // add zap splits
    if ($currentUser) {
        highlightTags.push(["zap", $currentUser.pubkey, "2"])
        highlightTags.push(["zap", article.pubkey, "8"])
    }

    const blossom = createBlossom({ user: author });

    let image: string | undefined;
    let userProfile: UserProfileType | null | undefined;

    $: {
        image = article.image
        if (!image && !isPreview) image ??= userProfile?.image;
    }

    const summary = getSummary(article);
</script>

<UserProfile user={author} bind:userProfile>
    <ArticleRenderShell {isFullVersion} {isPreview}>
        <div slot="title">
            {article.title??"Untitled"}
        </div>

        <div slot="summary" class:hidden={!summary}>
            {summary}
        </div>

        <div slot="tags">
            <EventTags event={article} />
        </div>

        <div slot="image">
            {#if image}
                <img use:blossom src={image} alt={article.title} class="w-full h-full object-cover opacity-50" />
            {:else}
                <div class="w-full h-full bg-base-100 opacity-50"></div>
            {/if}
        </div>

        <div slot="zaps">
            <ItemViewZaps event={article} />
        </div>

        <div slot="content">
            <HighlightingArea tags={highlightTags}>
                <HighlightedContent event={article} {highlights} />

                {#if !isFullVersion}
                    <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                        <UpgradeButton event={article} />
                    </div>
                {/if}
            </HighlightingArea>
        </div>
    </ArticleRenderShell>
</UserProfile>