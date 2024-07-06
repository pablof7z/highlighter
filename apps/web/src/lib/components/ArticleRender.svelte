<script lang="ts">
	import { NavigationOption } from './../../app.d.js';
	import { getSummary } from '$utils/article';
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKTag, NDKKind, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { createEventDispatcher, onDestroy, onMount } from "svelte";
	import HighlightingArea from './HighlightingArea.svelte';
	import HighlightedContent from './HighlightedContent.svelte';
	import currentUser from '$stores/currentUser';
	import ItemViewZaps from './Event/ItemView/ItemViewZaps.svelte';
	import { createBlossom } from '$utils/blossom.js';
	import UserProfile from './User/UserProfile.svelte';
	import { UserProfileType } from '../../app';
	import ArticleRenderShell from './Event/Article/ArticleRenderShell.svelte';
	import { EventContent } from '@nostr-dev-kit/ndk-svelte-components';
    import { inview } from 'svelte-inview';
	import HorizontalOptionsList from './HorizontalOptionsList.svelte';
	import { layout, pageHeader } from '$stores/layout.js';
	import { Readable } from 'svelte/store';

    export let article: NDKArticle;
    const author = article.author;
    export let isFullVersion: boolean;
    export let isPreview = false;
    export let navigationOptions: NavigationOption[] | undefined = undefined;
    export let highlights: Readable<NDKHighlight[]>;

    const dispatcher = createEventDispatcher();

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
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

    function toolbarInViewChange(e) {
        const { inView } = e.detail;
        if (inView) {
            $layout.navigation = false;
        } else {
            $layout.navigation = navigationOptions;
        }
    }

    let hasZaps: boolean;
</script>

<UserProfile user={author} bind:userProfile>
    <ArticleRenderShell
        {skipImage}
        {isFullVersion}
        {isPreview}
    >
        <div slot="title" use:inview on:inview_change={titleViewChange}>
            {article.title??"Untitled"}
        </div>

        <div slot="summary" class:hidden={!summary}>
            {summary}
        </div>

        <!-- <div slot="tags">
            <EventTags event={article} />
        </div> -->

        <svelte:element
            this={image ? 'img' : 'div'}
            slot="image"
            use:blossom
            class="w-full object-cover bg-secondary max-sm:h-[203px]"
            {...(image ? { src: image } : {})}
        />

        <div slot="zaps" class:hidden={!hasZaps}>
            <ItemViewZaps event={article} bind:hasZaps class="border-t border-border py-4 responsive-padding" />
        </div>

        <div slot="toolbar" use:inview on:inview_change={toolbarInViewChange}>
            <HorizontalOptionsList options={navigationOptions} class="border-t border-border py-4 responsive-padding " />
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