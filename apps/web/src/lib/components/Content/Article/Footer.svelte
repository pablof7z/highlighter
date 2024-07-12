<script lang="ts">
	import Zap from "$components/Events/Zaps/Zap.svelte";
    import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, Check, Lightning, Repeat } from "phosphor-svelte";
	import Tts from '$components/Actions/TTS/TTS.svelte';
	import ReaderButton from "$components/Event/Article/ReaderButton.svelte";
	import { openModal } from "$utils/modal";
	import ShareModal from "$modals/ShareModal.svelte";
	import BookmarkFooterButton from "$components/Layout/Footers/Buttons/BookmarkFooterButton.svelte";
    import ZapButton from "$components/Layout/Footers/Buttons/Zap.svelte";

    export let article: NDKArticle;
    export let mainView: 'zap' | 'tts' | "content" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";

    let collapse: () => void;
    let zapped = false;

    function onZapping(){
        collapse();
    }
    
    function onZapped() {
        collapse();
        zapped = true;
    }

    let content = "";

    function cancelContentEditor() {
        mainView = undefined;
        content = "";
    }

    function publishContentEditor() {
        mainView = undefined;
        console.log(content);
        content = "";
    }
</script>

<Footer.Shell
    bind:collapsed
    bind:mainView
    bind:collapse
    let:open
>
    {#if collapsed}
        <ZapButton target={article} bind:zapped {open} />

        <ReaderButton
            {article}
            variant="outline"
            class="rounded w-[38px] h-[38px] p-0 flex-none"
            onShow={() => mainView = 'tts' }
        />

        <ContentEditor
            class="
                grow h-11 border border-border bg-background rounded px-4 p-2 !text-lg
                placeholder:text-muted-foreground placeholder:!text-lg scrollbar-hide

            "
            {placeholder}
            allowMarkdown={false}
            on:focus={() => { mainView = "content" }}
            toolbar={false}
            bind:content
        />
    {:else if mainView === "content"}
        <div class="flex flex-row justify-between w-full">
            <Button variant="outline" on:click={cancelContentEditor}>
                Cancel
            </Button>

            <Button variant="accent" on:click={publishContentEditor}>
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
        {:else if mainView === 'zap'}
            <Zap
                event={article}
                on:zap={onZapped}
                on:zapping={onZapping}
            />
        {:else if mainView === 'tts'}
            <Tts event={article} />
        {:else}
            <div class="grid grid-cols-3 gap-2">
                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                    on:click={() => openModal(ShareModal, { event: article })}
                >
                    <Repeat size={40} />
                    Share
                </Button>

                <BookmarkFooterButton event={article} />

                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4">
                    <BookmarkSimple size={40} />
                    Bookmark
                </Button>
            </div>
        {/if}
    </div>
</Footer.Shell>