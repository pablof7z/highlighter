<script lang="ts">
	import ItemFooter from '$components/Event/ItemView/ItemFooter.svelte';
	import {  userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKKind, type NDKEventId, NDKEvent, NDKZapInvoice } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { pageHeader } from "$stores/layout";
	import { getAuthorUrl, urlFromEvent } from "$utils/url";
	import { CardsThree, ChatCircle } from "phosphor-svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import ItemViewComments from "$views/Item/ItemViewComments.svelte";
	import { appMobileHideNewPostButton, appMobileView } from "$stores/app";
	import ArticleRender from "$components/ArticleRender.svelte";
	import HorizontalOptionsList from '$components/HorizontalOptionsList.svelte';
	import ItemLink from '$components/Events/ItemLink.svelte';

    export let article: NDKArticle;
    const author = article.author;
    export let editUrl: string | undefined = undefined;
    export let isFullVersion: boolean;

    /**
     * Whether to render as just a preview instead of rendering a full article (i.e. this is viewed from the editor's preview)
     */
    export let isPreview = false;

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
        // goto(`/${author.npub}/${dTag}`);
    }

    editUrl ??= `/articles/${article.tagValue("d")}/edit`;

    let authorUrl: string | undefined;
    let urlPrefix: string;
    
    $: urlPrefix = urlFromEvent(article, authorUrl);

    $appMobileHideNewPostButton = true;

    getAuthorUrl(author).then(url => authorUrl = url);

    $pageHeader ??= {};
    $: if (!isPreview) {
        if ($pageHeader?.props)
            $pageHeader.props.editUrl = editUrl;
        $pageHeader.footer = {
            component: ItemFooter,
            props: {
                event: article,
                urlPrefix
            }
        }
    }

    onDestroy(() => {
        if ($pageHeader?.footer)
            $pageHeader.footer = undefined;
        modularArticles.unsubscribe();
    });

    const modularArticles = $ndk.storeSubscribe({ kinds: [30040], "#e": [article.id] }, { subId: 'modular-articles' });
</script>

<ArticleRender
    {article}
    {isFullVersion}
    {isPreview}
    on:title:inview_change
/>

<h2 class="text-2xl">Linked from</h2>

{#each $modularArticles as article}
    <ItemLink event={article} />
{/each}

{#if !isPreview}
    <div class="flex flex-col responsive-padding">
        <HorizontalOptionsList options={[
            { name: "Comments", href: `${urlPrefix}/comments`, icon: ChatCircle, badge: "1" },
            { name: "Highlights", href: `${urlPrefix}/highlights`, icon: HighlightIcon },
            { name: "Curations", href: `${urlPrefix}/curations`, icon: CardsThree },
        ]} value="Comments" class="my-4" />

        <ItemViewComments event={article} />
    </div>
{/if}