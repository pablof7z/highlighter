<script lang="ts">
    import Input from '$components/ui/input/input.svelte';
	import { NDKArticle } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher } from "svelte";
	import { openModal } from "$utils/modal";
    import { Editor as EditorType } from 'svelte-tiptap'
	import CoverImageModal from "$modals/CoverImageModal.svelte";
	import { CaretRight, X } from "phosphor-svelte";
	import { Button } from '$components/ui/button';
    import * as Studio from '$components/Studio';
	import { Writable } from 'svelte/store';
	import * as Editor from '$components/Editor/';
	import Textarea from '$components/ui/textarea/textarea.svelte';
	import Versions from '../Drafts/Item/Versions.svelte';
	import { DraftItem } from '$stores/drafts';
	import { getDraftById } from '$utils/drafts';

    export let state: Writable<Studio.State<Studio.Type.Article>>;
    export let article: NDKArticle = $state.article;

    let draftItem: DraftItem | undefined;
    let editorElement: EditorType;

    $: {
        $state.article = article;
        if ($state.draftId) draftItem = getDraftById($state.draftId);
    }

    const dispatch = createEventDispatcher();

    let contentAreaElement: HTMLTextAreaElement;

    function onTitleKeyDown(e: KeyboardEvent) {
        if (contentAreaElement) contentAreaElement.focus();
    }

    function titleChanged() {
        dispatch("titleChanged");
    }

    function addCoverImage() {
        const onSaveCover = (a: NDKArticle) => {
            article = a;
        }
        openModal(CoverImageModal, { article, onSave: onSaveCover });
    }

	function summaryKeydown(e: KeyboardEvent): void {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            e.stopImmediatePropagation();
            if (editorElement) {
                editorElement.view.dom.focus();
            }
        }
	}
</script>

<div class="flex flex-col w-full relative responsive-padding gap-4">
    <Editor.Root
        bind:content={article.content}
        bind:editor={editorElement}
        placeholder="Start writing..."
    >
    <pre>{article.content}</pre>
        <div class="
            sticky top-[var(--header-height)] z-50 bg-background
            py-2
        ">
            <Editor.Toolbar />
        </div>

        {#if article.image}
            <div class="relative w-full">
                <img src={article.image} class="w-full h-full object-cover max-h-[40vh]" />
                <Button
                    variant="secondary"
                    class="absolute top-2 right-2"
                    size="icon"
                    on:click={() => article.image = undefined}
                >
                    <X size={24} />
                </Button>
            </div>
        {:else}
            <Button size="xs" variant="secondary" class="w-fit py-2" on:click={addCoverImage}>
                Add cover image <CaretRight size={16} class="ml-1 inline" />
            </Button> 
        {/if}

            
        <div class="flex flex-col w-full">
            <Input
                bind:value={article.title}
                class="!bg-transparent rounded-none !text-4xl font-['InterDisplay'] font-bold focus-visible:!ring-none focus-visible:!ring-offset-0 focus-visible:!border-none focus-visible:!outline-none !border-none focus:!border-none !p-0 focus:!ring-0 !text-foreground placeholder:text-muted-foreground/50"
                placeholder="Title"
                on:submit={onTitleKeyDown}
                on:change={titleChanged}
                style="field-sizing: normal;"
            />

            <Textarea
                bind:value={article.summary}
                bind:element={contentAreaElement}
                placeholder="Add a subtitle"
                on:keypress={summaryKeydown}
                class="
                    !bg-transparent font-light !text-lg text-muted-foreground placeholder:!font-light focus-visible:!ring-none focus-visible:!ring-offset-0 focus-visible:!border-none focus-visible:!outline-none !border-none focus:!border-none !p-0 rounded-none focus:!ring-0 font-['InterDisplay'] placeholder:text-muted-foreground/30
                    grow resize-none
                "
            />
        </div>

        <Editor.Shell class="article grow pb-[20vh] min-h-screen" bind:content={article.content} />
    </Editor.Root>
</div>

<div class="fixed bottom-4 left-4">
    {#if draftItem}
        <Versions item={draftItem} />
    {/if}
</div>