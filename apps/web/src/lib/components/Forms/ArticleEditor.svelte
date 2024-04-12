<script lang="ts">
    import Quill from 'quill';
    import Input from "$components/Forms/Input.svelte";
	import { UploadButton, ndk } from "@kind0/ui-common";
	import { NDKArticle, NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher, onMount } from "svelte";
    import quillEditorMention from "./quill-editor-mention.js";
    import "quill-mention";
	import { getContents } from './quill-editor-contents.ts.js';
	import { Image } from 'phosphor-svelte';

    export let article: NDKArticle = new NDKArticle($ndk, {
        content: "",
    } as NostrEvent);

    let quill: Quill;

    onMount(() => {
        quill = new Quill('#editor', {
            theme: 'snow',
            placeholder: "Write your heart out...",
            modules: {
                toolbar: "#toolbar-container",
                mention: {
                    source: quillEditorMention,
                    dataAttributes: ['id', 'value', 'avatar'],
                    renderItem: (data) => {
                        const div = document.createElement("div");
                        div.classList.add("flex", "flex-row", "items-center", "mention", "gap-3");
                        div.innerHTML = `<img src="${data.avatar}" class="w-7 h-7 rounded-full" />`;
                        const span = document.createElement("span");
                        span.innerText = data.value;
                        div.appendChild(span);
                        return div;
                    },
                }
            }
        });

        quill.setText(article.content)
        quill.on("text-change", () => {
            article.content = getContents(quill);
            dispatch("contentChanged");
        });
    })

    const dispatch = createEventDispatcher();

    let contentAreaElement: HTMLElement;

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }

    function fileUploaded(e: CustomEvent<{url: string, tags: NDKTag[]}>) {
        const {url, tags} = e.detail;
        if (url) {
            quill.insertText(quill.getSelection()?.index || 0, "\n");
            quill.insertEmbed(quill.getSelection()?.index || 0, "image", url);
            quill.insertText(quill.getSelection()?.index || 0, "\n");
        } else {
            console.error("Failed to upload file");
        }
    }
</script>

<div class="flex flex-col border-none border-neutral-800 sm:rounded-xl border">
    <div class="-mt-4 toolbar sticky z-40 top-16 bg-base-100/80  !backdrop-blur-[50px] !border-b !border-base-200" id="toolbar-container">
        <span class="ql-formats">
            <select class="ql-header"></select>
        </span>
        <span class="ql-formats">
            <button class="ql-bold"></button>
            <button class="ql-italic"></button>
            <button>
                <UploadButton class="!p-0" on:uploaded={fileUploaded}>
                    <Image class="w-full" />
                </UploadButton>
            </button>
        </span>
    </div>
    <div class="p-6 pb-0 w-full">
        <Input
            bind:value={article.title}
            color="black"
            class="!bg-transparent !text-3xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] placeholder:text-white/50 placeholder:font-normal"
            placeholder="Add a title"
            on:keydown={onTitleKeyDown}
            on:change={() => dispatch("titleChanged")}
        />
    </div>
    <div class="px-2 pt-0 flex flex-col gap-4">
        <!-- bind:value={article.content}
        on:keyup={() => dispatch("contentUpdate", article.content)}
        bind:element={contentAreaElement}
        on:change={() => dispatch("contentChanged")}
        fixedHeight={true} -->

        <div id="editor" />
    </div>
</div>

<style>
    #editor {
        min-height: 20vh;
        @apply text-lg font-serif;
        @apply w-full border-0;
        @apply flex flex-col items-stretch justify-stretch p-4;
    }

    #toolbar-container {
        @apply p-2;
        @apply !border-t-0 !border-l-0 !border-r-0;
        @apply flex flex-row items-center gap-1;
    }

    :global(.ql-editor) {
        @apply p-0 grow focus:!ring-0 focus:!outline-none !border-0;
    }

    .toolbar button {
        @apply !border-0 !rounded w-10 h-10 !p-2;
    }

    .toolbar button:hover, .toolbar .button:hover {
        @apply !bg-base-300;
    }

    :global(.ql-snow.ql-toolbar button svg *) {
        color: #ccc;
        stroke: #ccc;
    }
    :global(.ql-snow.ql-toolbar button:hover svg *) {
        stroke: white !important;
    }

    :global(.ql-active) {
        @apply !text-white !bg-base-300;
    }

    :global(.ql-active .ql-stroke) {
        stroke: white !important;
    }

    :global(.ql-picker-label) {
        @apply !border-0;
    }

    :global(.ql-picker-options) {
        @apply !bg-base-300 !border-0 rounded-box !p-4 !z-50;
        @apply text-white/50
    }

    :global(.ql-picker-item:hover, .ql-picker-item.ql-selected) {
        @apply !text-white;
    }

    :global(.ql-editor .mention) {
        @apply text-white font-medium;
    }

    :global(.ql-mention-list) {
        @apply bg-base-200 font-sans py-2 rounded-box;
    }

    :global(.ql-mention-list-item) {
        @apply px-4 py-1 text-base;
    }

    :global(.ql-mention-list-item.selected) {
        @apply bg-base-300 text-white;
    }
</style>