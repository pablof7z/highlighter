<script lang="ts">
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, CardsThree, Check, Lightning, Pen, Plus, Repeat } from "phosphor-svelte";
	import { createEventReply } from '$utils/event';
    import Zap from '$components/Footer/Views/Zap';
    import Curate from '$components/Footer/Views/Curate';
	import { goto } from '$app/navigation';
	import currentUser from '$stores/currentUser';
	import { scrollPercentage } from '$stores/layout';
    import { Progress } from "$lib/components/ui/progress";
	import HighlightTool from '$components/Footer/Views/HighlightTool';
	import { FooterView } from '$components/Footer';
	import HighlightViewer from '$components/Footer/Views/HighlightViewer';
	import Share from '$components/Footer/Views/Share';
	import ZapPrompt from '$components/Footer/Views/ZapPrompt';
	import Comment from '$components/Footer/Views/Comment';

    export let article: NDKArticle;
    export let forceMainView: 'zap' | 'tts' | 'curation' | "content" | "new-collection" | undefined = undefined;
    export let placeholder = "Reply";

    $: if (forceMainView) {
        open(forceMainView);
        forceMainView = undefined;
    }

    let zapped = false;

    function onZapped() {
        zapped = true;
    }

    function edit() {
        goto(`/studio/article?eventId=${article.encode()}`)
        open(false)
    }

    const defaultViews: FooterView[] = [
        {...Zap, buttonProps: { zapped }, props: { event: article, onZapped }},
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

    let open: Footer.OpenFn;
    let views: FooterView[] | undefined = defaultViews;
</script>

<Footer.Shell
    bind:open
    {views}
>
    <div class="absolute top-0 left-0 h-1 right-0">
        <Progress value={$scrollPercentage} class="rounded-sm h-1" barClass="dark:bg-gold light:bg-foreground" />
    </div>

    <div slot="main">
        <div class="grid grid-cols-3 lg:grid-cols-5 gap-2">

            <Share.LargeButton {open} event={article} />
            <Zap.LargeButton {open} />
            <Curate.LargeButton {open} />

            {#if $currentUser?.pubkey === article.pubkey}
                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                    on:click={edit}
                >
                    <Pen size={40} />
                    Edit
                </Button>
            {/if}
        </div>
    </div>
</Footer.Shell>