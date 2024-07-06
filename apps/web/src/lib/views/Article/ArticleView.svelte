<script lang="ts">
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ndk } from "$stores/ndk.js";
	import { type NDKArticle, NDKKind, NDKEvent, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { layout, pageHeader } from "$stores/layout";
	import { getAuthorUrl, urlFromEvent } from "$utils/url";
	import { ChatCircle } from "phosphor-svelte";
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import ItemViewComments from "$views/Item/ItemViewComments.svelte";
	import { appMobileHideNewPostButton, appMobileView } from "$stores/app";
	import { derived } from "svelte/store";
	import { NavigationOption } from "../../../app";
	import HorizontalOptionsList from "$components/HorizontalOptionsList.svelte";
	import ArticleRender from "$components/ArticleRender.svelte";
	import Footer from "./Footer.svelte";

    export let article: NDKArticle;
    const author = article.author;
    export let editUrl: string | undefined = undefined;
    export let isFullVersion: boolean;

    /**
     * Whether to render as just a preview instead of rendering a full article (i.e. this is viewed from the editor's preview)
     */
    export let isPreview = false;

    $layout ??= {};
    $layout.sidebar = false;

    const relatedEvents = $ndk.storeSubscribe([
        { kinds: [NDKKind.Highlight], ...article.filter() },
        { kinds: [NDKKind.Text, NDKKind.GroupReply ], ...article.filter() },
        { kinds: [NDKKind.Zap], ...article.filter() },
        { kinds: [NDKKind.Repost, NDKKind.GenericRepost], ...article.filter() },
        { kinds: [NDKKind.Text], "#q": [article.tagId(), article.id] },
    ], { subId: 'article-view-events' });

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
        relatedEvents.unsubscribe();
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

    $layout.footer = {
        component: Footer,
        props: { article }
    }

    $pageHeader ??= {};
    $: if (!isPreview) {
        if ($pageHeader?.props)
            $pageHeader.props.editUrl = editUrl;
    }

    onDestroy(() => {
        if ($layout?.footer)
            $layout.footer = undefined;
    });

    let navigationOptions: NavigationOption[] = [];

    function isShareEvent(e: NDKEvent) {
        if (e.kind === NDKKind.Repost || e.kind === NDKKind.GenericRepost) return true;
        const qTag = e.tagValue("q");
        if (qTag === article.tagId() || qTag === article.id) return true;
        return false;
    }

    $: if (relatedEvents) {
        const comments = $relatedEvents.filter(e => e.kind === NDKKind.Text || e.kind === NDKKind.GroupReply);
        const highlights = $relatedEvents.filter(e => e.kind === NDKKind.Highlight);
        const shares = $relatedEvents.filter(e => isShareEvent(e));
        
        navigationOptions = [
            { name: "Article", href: urlPrefix, buttonProps: {variant: 'accent'} },
            
            // { name: "Curations", href: `${urlPrefix}/curations`, icon: CardsThree },
        ];

        if (comments.length) {
            navigationOptions.push({ name: "Comments", href: `${urlPrefix}/comments`, badge: comments.length.toString() });
        }

        if (highlights.length) {
            navigationOptions.push({ name: "Highlights", href: `${urlPrefix}/highlights`, badge: highlights.length.toString() });
        }

        if (shares.length) {
            navigationOptions.push({ name: "Shares", href: `${urlPrefix}/shares`, badge: shares.length.toString() });
        }
    }

    const highlights = derived(relatedEvents, ($relatedEvents) => {
        return $relatedEvents.filter(e => e.kind === NDKKind.Highlight)
            .map(e => NDKHighlight.from(e));
    });
</script>

<ArticleRender
    {article}
    {isFullVersion}
    {isPreview}
    {navigationOptions}
    {highlights}
    on:title:inview_change
    on:toolbar:inview_change={(e) => toolbarInView = e.detail.inView}
/>

{#if !isPreview}
    <div class="flex flex-col responsive-padding">
        <HorizontalOptionsList options={[
            { name: "Comments", href: `${urlPrefix}/comments`, icon: ChatCircle, badge: "1" },
            { name: "Highlights", href: `${urlPrefix}/highlights`, icon: HighlightIcon },
            // { name: "Curations", href: `${urlPrefix}/curations`, icon: CardsThree },
        ]} value="Comments" class="my-4" />

        <ItemViewComments event={article} />
    </div>
{/if}