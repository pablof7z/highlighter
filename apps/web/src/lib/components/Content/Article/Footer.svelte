<script lang="ts">
	import Zap from "$components/Events/Zaps/Zap.svelte";
    import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import FooterShell from "$components/PageElements/Mobile/FooterShell.svelte";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, Check, Lightning, Repeat } from "phosphor-svelte";
	import Tts from '$components/Actions/TTS/TTS.svelte';
	import ReaderButton from "$components/Event/Article/ReaderButton.svelte";
	import { openModal } from "$utils/modal";
	import ShareModal from "$modals/ShareModal.svelte";
	import BookmarkFooterButton from "$components/Layout/Footers/Buttons/BookmarkFooterButton.svelte";

    export let article: NDKArticle;
    export let mainView: 'zap' | 'tts' | "content" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";

    let zapped = false;
    function onZapped() {
        mainView = undefined;
        collapsed = true;
        zapped = true;
        setTimeout(() => zapped = false, 2000);
    }

    let content = "";

    function setMainView(view: 'zap' | 'tts' | "content") {
        mainView = view;
        collapsed = false;
    }

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

<FooterShell
    bind:collapsed
    bind:mainView
>
    {#if collapsed}
        <Button
            variant={zapped ? undefined : "accent"}
            class="
                flex-none w-12 h-12 p-2
                rounded
                {zapped ? 'bg-green-500' : ''}
            "
            on:click={() => {
                setMainView('zap')
            }}
        >
            {#if !zapped}
                <Lightning class="w-full h-full" weight="fill" />
            {:else}
                <Check class="w-full h-full" weight="bold" />
            {/if}
        </Button>

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
</FooterShell>