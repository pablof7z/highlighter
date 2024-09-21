<script lang="ts">
	import Highlight from './../../Highlight.svelte';
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, CardsThree, Check, Lightning, Pen, Plus, Repeat } from "phosphor-svelte";
    import Zap from "$components/Footer/Buttons/Zap.svelte";
    import Curate from '$components/Footer/Views/Curate';
	import { goto } from '$app/navigation';
	import currentUser from '$stores/currentUser';
	import { scrollPercentage } from '$stores/layout';
    import { Progress } from "$lib/components/ui/progress";
	import HighlightTool from '$components/Footer/Views/HighlightTool';
	import { FooterView } from '$components/Footer';
	import HighlightViewer from '$components/Footer/Views/HighlightViewer';
	import ZapPrompt from '$components/Footer/Views/ZapPrompt';
	import Comment from '$components/Footer/Views/Comment';
	import Bookmark from "$components/Footer/Buttons/Bookmark.svelte";
	import Comments from "$components/Footer/Buttons/Comments.svelte";
	import Highlights from "$components/Footer/Buttons/Highlights.svelte";
	import Share from "$components/Footer/Buttons/Share.svelte";
	import { activeSelection } from '$stores/highlight-tool';

    export let article: NDKArticle;
    export let placeholder = "Reply";

    let zapped = false;

    function onZapped() {
        zapped = true;
    }

    function edit() {
        goto(`/studio/article?eventId=${article.encode()}`)
    }

    const defaultViews: FooterView[] = [
        {...Curate, buttonProps: { zapped }, props: { event: article, onZapped }},
        {...HighlightTool, props: { event: article }},
        {...HighlightViewer, props: { article }},
        {...Curate, props: { article }},
        {...Comment, props: { event: article, placeholder: 'Comment...' }},
    ];

    // we ensure a minimum length of 500 characters since this component
    // reacts to scrolling and we don't want it to show up immediately
    if (article.content.length > 500) {
        defaultViews.push({...ZapPrompt, buttonProps: { zapped }, props: { article }});
    }

    let views: FooterView[] | undefined = defaultViews;
</script>

<Footer.Shell
>
    <!-- <div class="absolute top-0 left-0 h-1 right-0">
        <Progress value={$scrollPercentage} class="rounded-sm h-1" barClass="dark:bg-gold light:bg-foreground" />
    </div> -->
    {#if $activeSelection}
        <HighlightTool.Toolbar event={article} />
    {:else}
        <div class="flex flex-row justify-center w-1/5"><Zap event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Comments event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Highlights event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Share event={article} /></div>
        <div class="flex flex-row justify-center w-1/5"><Bookmark event={article} /></div>
    {/if}
</Footer.Shell>