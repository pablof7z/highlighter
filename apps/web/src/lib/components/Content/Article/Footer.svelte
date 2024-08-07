<script lang="ts">
	import NewCuration from './NewCuration.svelte';
    import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, CardsThree, Check, Lightning, Pen, Plus, Repeat } from "phosphor-svelte";
	import Tts from '$components/Actions/TTS/TTS.svelte';
	import ReaderButton from "$components/Event/Article/ReaderButton.svelte";
	import { openModal } from "$utils/modal";
	import ShareModal from "$modals/ShareModal.svelte";
	import BookmarkFooterButton from "$components/Layout/Footers/Buttons/BookmarkFooterButton.svelte";
	import { createEventReply } from '$utils/event';
    import Zap from '$components/Footer/Views/Zap';
    import Curate from '$components/Footer/Views/Curate';
	import { goto } from '$app/navigation';
	import currentUser from '$stores/currentUser';
	import { scrollPercentage } from '$stores/layout';
    import { Progress } from "$lib/components/ui/progress";
	import Name from '$components/User/Name.svelte';
	import HighlightTool from '$components/Footer/Views/HighlightTool';
	import { FooterView } from '$components/Footer';
	import HighlightViewer from '$components/Footer/Views/HighlightViewer';
	import { userArticleCurations } from '$stores/session';

    export let article: NDKArticle;
    export let forceMainView: 'zap' | 'tts' | 'curation' | "content" | "new-collection" | undefined = undefined;
    export let mainView: 'zap' | 'tts' | 'curation' | "content" | "new-collection" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";

    $: if (forceMainView) {
        open(forceMainView);
        forceMainView = undefined;
    }

    let forceSaveNewCollection = false;
    let forceSaveCollections = false;

    let zapped = false;

    function onZapped() {
        zapped = true;
    }

    let content = "";

    function cancelContentEditor() {
        mainView = undefined;
        content = "";
    }

    async function _onPublish(content: string) {
        const reply = createEventReply(article);
        reply.content = content;
        await reply.sign();
        reply.publish();
    }

    function curation() {
        if ($userArticleCurations.size === 0) {
            open('new-collection');
        } else {
            open('curation');
        }
    }

    function publishContentEditor() {
        mainView = undefined;
        console.log(content);
        content = "";
    }

    function edit() {
        goto(`/studio/article?eventId=${article.encode()}`)
        open(false)
    }

    let open: Footer.OpenFn;
    let views: FooterView[] | undefined = [
        {...Zap, buttonProps: { zapped }, props: { event: article, onZapped }},
        {...HighlightTool, props: { event: article }},
        {...HighlightViewer, props: { article }},
        {...Curate, props: { article }},
    ];

    let zapPrompt = false;

    let onPublish = _onPublish;

    $: if ($scrollPercentage > 90) {
        zapPrompt = true;
        onPublish = undefined;
        views = undefined;
    }
</script>

<Footer.Shell
    bind:collapsed
    bind:mainView
    bind:open
    placeholder="Comment"
    {onPublish}
    {views}
>
    <div class="absolute top-0 left-0 h-1 right-0">
        <Progress value={$scrollPercentage} class="rounded-sm h-1" barClass="bg-gold" />
    </div>
    {#if collapsed}
        {#if zapPrompt}
            <div class="flex flex-row items-center w-full justify-between">
                <div class="text-foreground">
                    You've reached the end of the article. Would you like to reward
                    <Name class="text-gold" pubkey={article.pubkey} /> for their work?
                </div>

                <div class="flex flex-row gap-2">
                    <Button variant="gold" on:click={() => {
                        views = [{...Zap, buttonProps: { zapped }, props: { event: article, onZapped }}];
                        onPublish = _onPublish;
                        zapPrompt = false;
                        open('zap')
                    }}>
                        <Check size={24} class="mr-2" />
                        Yes!
                    </Button>

                    <Button variant="secondary" on:click={() => open(false)}>
                        No, thanks
                    </Button>
                </div>
            </div>
        {:else}
            <ReaderButton
                {article}
                variant="outline"
                class="rounded w-[38px] h-[38px] p-0 flex-none"
                onShow={() => open('tts')}
            />
        {/if}
    {:else if mainView === "content"}
        <div class="flex flex-row justify-between w-full">
            <Button variant="link" on:click={cancelContentEditor}>
                Cancel
            </Button>

            <Button on:click={publishContentEditor}>
                Publish
            </Button>
        </div>
    {/if}

    <div slot="main">
        {#if mainView === 'content'}
            <ContentEditor
                class="
                    grow !min-h-[300px] border border-border bg-background rounded-xl px-4 p-2 text-lg
                    placeholder:text-muted-foreground placeholder:!text-xs
                "
                {placeholder}
                allowMarkdown={false}
                toolbar={false}
                autofocus
                bind:content
            />
        {:else if mainView === 'tts'}
            <Tts event={article} />
        {:else if mainView === 'new-collection'}
            
        {:else}
            <div class="grid grid-cols-3 lg:grid-cols-5 gap-2">
                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                    on:click={() => openModal(ShareModal, { event: article })}
                >
                    <Repeat size={40} />
                    Share
                </Button>

                <BookmarkFooterButton event={article} />

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
        {/if}
    </div>
</Footer.Shell>