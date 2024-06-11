<script lang="ts">
	import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKKind, type NDKEventId, NDKEvent, NDKZapInvoice } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import ArticleRender from './ArticleRender.svelte';
	import { pageHeader } from "$stores/layout";
	import ItemFooter from "./Event/ItemView/ItemFooter.svelte";
	import { getAuthorUrl, urlFromEvent } from "$utils/url";
	import HorizontalOptionsList from "./HorizontalOptionsList.svelte";
	import { CardsThree, ChatCircle } from "phosphor-svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import ItemViewComments from "$views/Item/ItemViewComments.svelte";

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

    getAuthorUrl(author).then(url => authorUrl = url);

    $pageHeader ??= {};
    $: if (!isPreview) {
        if ($pageHeader?.props)
            $pageHeader.props.editUrl = editUrl;
        $pageHeader.subNavbarOptions = [
            { name: "Comments", href: `${urlPrefix}/comments`, icon: ChatCircle, badge: "1" },
            { name: "Highlights", href: `${urlPrefix}/highlights`, icon: HighlightIcon },
            { name: "Curations", href: `${urlPrefix}/curations`, icon: CardsThree },
        ];
        $pageHeader.footer = {
            component: ItemFooter,
            props: {
                event: article,
                urlPrefix
            }
        }
    }
</script>

<ArticleRender
    {article}
    {isFullVersion}
    {isPreview}
/>

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