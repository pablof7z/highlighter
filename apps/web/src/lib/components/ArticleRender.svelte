<script lang="ts">
	import { getSummary } from '$utils/article';
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKTag, NDKKind } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import HighlightingArea from './HighlightingArea.svelte';
	import HighlightedContent from './HighlightedContent.svelte';
	import EventTags from './Events/EventTags.svelte';
	import currentUser from '$stores/currentUser';
	import ItemViewZaps from './Event/ItemView/ItemViewZaps.svelte';
	import { createBlossom } from '$utils/blossom.js';
	import UserProfile from './User/UserProfile.svelte';
	import { UserProfileType } from '../../app';
	import ArticleRenderShell from './Event/Article/ArticleRenderShell.svelte';
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';
    import { inview } from 'svelte-inview';

    export let article: NDKArticle;
    const author = article.author;
    export let isFullVersion: boolean;
    export let isPreview = false;

    const dispatcher = createEventDispatcher();

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

    let skipImage = true;

    $: skipImage = !article.image;

    function titleViewChange(e) {
        const { inView } = e.detail;
        dispatcher("title:inview_change", inView);
    }
</script>

<UserProfile user={author} bind:userProfile>
    <ArticleRenderShell {skipImage} {isFullVersion} {isPreview}>
        <div slot="title" use:inview  on:inview_change={titleViewChange}>
            {article.title??"Untitled"}
        </div>

        <div slot="summary" class:hidden={!summary}>
            {summary}
        </div>

        <div slot="tags">
            <EventTags event={article} />
        </div>

        <svelte:element
            this={image ? 'img' : 'div'}
            slot="image"
            use:blossom
            class="w-full h-full object-cover opacity-50 bg-secondary"
            {...(image ? { src: image } : {})}
        />

        <div slot="zaps">
            <ItemViewZaps event={article} />
        </div>

        <div slot="content" class="break-inside max-sm:w-[calc(100vw-1rem)]">
            {#if !isPreview}
                <HighlightingArea tags={highlightTags}>
                    <HighlightedContent event={article} {highlights} />

                    {#if !isFullVersion}
                        <div class="absolute bottom-0 right-0 bg-gradient-to-t from-background to-transparent via-background/70 w-full h-2/3 flex flex-col items-center justify-center">
                            <UpgradeButton event={article} />
                        </div>
                    {/if}
                </HighlightingArea>
            {:else}
                <EventContent
                    ndk={$ndk}
                    event={article}
                    class="prose-lg leading-8"
                />
            {/if}
        </div>
    </ArticleRenderShell>
</UserProfile>