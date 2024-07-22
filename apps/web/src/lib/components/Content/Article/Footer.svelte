<script lang="ts">
	import NewCuration from './NewCuration.svelte';
    import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import * as Footer from "$components/Footer";
	import { Button } from "$components/ui/button";
    import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { BookmarkSimple, CardsThree, Check, Lightning, Repeat } from "phosphor-svelte";
	import Tts from '$components/Actions/TTS/TTS.svelte';
	import ReaderButton from "$components/Event/Article/ReaderButton.svelte";
	import { openModal } from "$utils/modal";
	import ShareModal from "$modals/ShareModal.svelte";
	import BookmarkFooterButton from "$components/Layout/Footers/Buttons/BookmarkFooterButton.svelte";
	import Curation from "./Curation.svelte";
	import { createEventReply } from '$utils/event';
    import Zap from '$components/Footer/Views/Zap';

    export let article: NDKArticle;
    export let mainView: 'zap' | 'tts' | 'curation' | "content" | "new-collection" | undefined = undefined;
    export let collapsed = true;
    export let placeholder = "Reply";

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

    async function onPublish(content: string) {
        const reply = createEventReply(article);
        reply.content = content;
        await reply.sign();
        reply.publish();
    }

    function publishContentEditor() {
        mainView = undefined;
        console.log(content);
        content = "";
    }

    let open: (view?: string | false) => void;
</script>

<Footer.Shell
    bind:collapsed
    bind:mainView
    bind:open
    {onPublish}
    buttons={[
        {...Zap, buttonProps: { zapped }, props: { event: article, onZapped }}
    ]}
>
    {#if collapsed}
        <ReaderButton
            {article}
            variant="outline"
            class="rounded w-[38px] h-[38px] p-0 flex-none"
            onShow={() => open('tts')}
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
    {:else if mainView === 'curation'}
        <div class="flex flex-row justify-between w-full gap-2">
            <Button on:click={() => open('new-collection')}>
                New Collection
            </Button>

            <Button variant="accent" on:click={() => forceSaveCollections = true}>
                Save
            </Button>
        </div>
    {:else if mainView === 'new-collection'}
        <div class="flex flex-row justify-between w-full gap-2">
            <Button on:click={() => open('curation')}>
                Cancel
            </Button>

            <Button variant="accent" on:click={() => forceSaveNewCollection = true}>
                Save
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
        {:else if mainView === 'curation'}
            <Curation
                {article}
                bind:forceSave={forceSaveCollections}
                on:close={() => open(false)}
            />
        {:else if mainView === 'new-collection'}
            <NewCuration
                {article}
                bind:forceSave={forceSaveNewCollection}
                on:close={() => open(false)}
            />
        {:else}
            <div class="grid grid-cols-3 gap-2">
                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                    on:click={() => openModal(ShareModal, { event: article })}
                >
                    <Repeat size={40} />
                    Share
                </Button>

                <BookmarkFooterButton event={article} />

                <Button variant="outline" class="footer-button flex flex-col items-center gap-2 h-auto text-lg text-foreground bg-opacity-50 p-4"
                    on:click={() => open('curation')}
                >
                    <CardsThree size={40} />
                    Curate
                </Button>
            </div>
        {/if}
    </div>
</Footer.Shell>