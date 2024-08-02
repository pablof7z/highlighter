<script lang="ts">
	import { NDKArticle, NDKTag } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher, onMount } from "svelte";
    import QuillMarkdown from 'quilljs-markdown';
    import 'quill-paste-smart';
    import quillEditorMention from "./quill-editor-mention.js";
	import { getContents } from './quill-editor-contents.js';
	import { Image } from 'phosphor-svelte';
	import { EventContent, prettifyNip05 } from '@nostr-dev-kit/ndk-svelte-components';
	import { wysiwygEditor } from '$stores/settings.js';
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { newToasterMessage } from "$stores/toaster.js";
	import Checkbox from "./Checkbox.svelte";
    import Tiptap from "$components/Editor/Tiptap.svelte"
	import { ndk } from "$stores/ndk.js";

    export let content: string = "";
    export let placeholder = "Write your heart out...";
    export let toolbar = true;
    export let autofocus = false;
    export let allowMarkdown = true;
    export let enterSubmits = false;
    export let forceWywsiwyg = !toolbar;

    const dispatch = createEventDispatcher();

    let editorEl: HTMLElement;
    let toolbarEl: HTMLElement;

    let quill: any;

    let uploadBlob: Blob;

    async function enableEditor() {
        const {default: Quill} = await import('quill');
        const { default: QuillImageDropAndPaste } = await import ('quill-image-drop-and-paste');
        await import ("quill-mention");
        Quill.register('modules/imageDropAndPaste', QuillImageDropAndPaste)

        const options: any = {
            theme: 'snow',
            placeholder,
            modules: {
                imageDropAndPaste: {
                    // add an custom image handler
                    handler: (imageDataUrl, type, imageData) => {
                        uploadBlob = imageData.toBlob()
                        const img = editorEl.querySelector(`img[src^="data:image"]`);
                        if (img) img.classList.add('animate-pulse');
                    }
                },
                toolbar: toolbar ? { container: toolbarEl } : false,
                keyboard: {
                    bindings: {
                        justEnter: {
                            key: 'Enter',
                            handler: () => {
                                if (enterSubmits) {
                                    dispatch("submit");
                                } else {
                                    const range = quill.getSelection();
                                    if (range) quill.insertText(range.index, "\n");
                                }
                            }
                        },
                        shiftEnter: {
                            key: 'Enter',
                            shiftKey: true,
                            handler: () => {
                                if (enterSubmits) {
                                    const range = quill.getSelection();
                                    if (range) quill.insertText(range.index, "\n");
                                }
                            }
                        },
                        // when cmd+enter dispatch a submit event
                        cmdEnter: {
                            key: 'Enter',
                            metaKey: true,
                            handler: () => {
                                dispatch("submit");
                            }
                        },
                        shiftCmdEnter: {
                            key: 'Enter',
                            metaKey: true,
                            shiftKey: true,
                            handler: () => {
                                dispatch("forceSubmit");
                            }
                        }
                        // when the down key is pressed and we are at the last line
                        // dispatch a next event
                        // next: {
                        //     key: 40,
                        //     handler: () => {
                        //         const range = quill.getSelection();
                        //         const lines = quill.getLines();
                        //         console.log(lines);
                        //         if (range) {
                        //             const line = quill.getLine(range.index);
                        //             console.log(line);
                        //             // if (line && line.next == null) {
                        //             //     dispatch("next");
                        //             // }
                        //         }
                        //     }
                        // },
                    }
                },
                mention: {
                    source: quillEditorMention,
                    dataAttributes: ['id', 'value', 'avatar', "followed", "nip05"],
                    renderItem: (data) => {
                        const div = document.createElement("div");
                        div.classList.add("flex", "flex-row", "items-center", "mention", "gap-3", "cursor-pointer");
                        div.innerHTML = `<img src="${data.avatar}" class="w-7 h-7 rounded-full" />`;
                        const span = document.createElement("span");
                        span.classList.add("grow");
                        span.innerText = data.value;
                        div.appendChild(span);
                        if (typeof data.nip05 === "string") {
                            const nip05Span = document.createElement("span");
                            nip05Span.innerText = prettifyNip05(data.nip05, 30);
                            nip05Span.classList.add("text-xs", "opacity-40", "truncate");
                            div.appendChild(nip05Span);
                        }
                        return div;
                    },
                }
            }
        };

        if (!allowMarkdown) options.formats = ['mention'];

        
        quill = new Quill(editorEl, options);
        new QuillMarkdown(quill, {})
        quill.on("text-change", () => {
            content = getContents(quill);
            dispatch("contentChanged");
        });

        const editorChild = editorEl.firstChild as HTMLElement;
        editorChild.addEventListener("focusin", () => dispatch("focus"));
        editorChild.addEventListener("focusout", () => dispatch("blur"));

        if (autofocus) quill.focus();
    }

    onMount(async () => {
        if ($wysiwygEditor || forceWywsiwyg) enableEditor();
    })

    function fileUploaded(e: CustomEvent<{url: string, tags: NDKTag[]}>) {
        const {url, tags} = e.detail;
        if (url) {
            const img = document.querySelector(`img[src^="data:image"]`);
            let index: number | undefined;
            if (img) {
                const imgBlot = Quill.find(img);
                console.log(imgBlot)
                // remove imgBlo from quill
                if (imgBlot) {
                    const imgIndex = quill.getIndex(imgBlot);
                    if (imgIndex !== null) {
                        quill.deleteText(imgIndex, 1);
                        index = imgIndex;
                    } else {
                        console.log("unable to find image index")
                    }
                } else {
                    console.log("unable to find image blot")
                }
            } else {
                console.log("unable to find image")
            }

            if (index === undefined) {
                index = quill.getSelection()?.index || 0;
            }

            quill.insertText(index, "\n");
            quill.insertEmbed(index, "image", url);
        } else {
            newToasterMessage("Failed to upload image", "error");
        }
    }

    function toggleEditor() {
        if ($wysiwygEditor) {
            enableEditor();
        } else {
        }
    }
</script>

<div class="flex flex-col border-none sm:rounded-xl border grow">
    {#if toolbar}
        <div class="flex flex-row items-start justify-between font-sans">
        <div bind:this={toolbarEl} class="-mt-4 toolbar sticky z-40 top-[var(--navbar-height)] bg-background/80  !backdrop-blur-[50px] toolbar-container w-full">
            {#if $wysiwygEditor || forceWywsiwyg}
                <span class="ql-formats">
                    <select class="ql-header"></select>
                </span>
                <span class="ql-formats">
                    <button class="ql-bold"></button>
                    <button class="ql-italic"></button>
                    <button class="ql-link"></button>
                    <button>
                        <BlossomUpload class="!p-0" on:uploaded={fileUploaded} bind:blob={uploadBlob}>
                            <Image class="w-full" />
                        </BlossomUpload>
                    </button>
                </span>
                <span class="ql-formats">
                    <button class="ql-formula"></button>
                </span>
            {/if}
        </div>

            <Checkbox
                class="border-none text-muted-foreground text-sm"
                type="switch"
                bind:value={$wysiwygEditor}
                on:change={toggleEditor}
            >
                WYSIWYG
            </Checkbox>
        </div>
    {/if}
    {#if $$slots.belowToolbar}
        <slot name="belowToolbar" />
    {/if}
    <div class="pt-0 flex flex-col gap-4 transition-all duration-100 {$$props.class??""}">
        {#if $wysiwygEditor || forceWywsiwyg}
            <div bind:this={editorEl} class="
                editor h-full {$$props.class??""}
            ">
                <EventContent ndk={$ndk} content={content} event={new NDKArticle($ndk, { content })} />
            </div>
        {:else}
            <textarea
                bind:value={content}
                {placeholder}
                class="
                    editor
                    !bg-transparent border-none {$$props.class??""}
                "
            />
        {/if}
    </div>
</div>

<style>
    .editor {
        @apply w-full border-0;
        @apply flex flex-col items-stretch justify-stretch text-foreground;
    }

    .toolbar-container {
        @apply p-2;
        @apply !border-t-0 !border-l-0 !border-r-0;
        @apply flex flex-row items-center gap-1 mb-4;
    }

    :global(.ql-editor.ql-blank::before) {
        @apply text-muted-foreground left-0 right-0;
        font-style: normal;
    }

    :global(.ql-editor) {
        @apply !p-0 grow focus:!ring-0 focus:!outline-0 focus-visible:!outline-none !border-0;
    }

    :global(.ql-container) {
    }

    .toolbar button {
        @apply !border-0 !rounded w-10 h-10 !p-2;
    }

    .toolbar button:hover, .toolbar .button:hover {
        @apply !bg-foreground/20;
    }

    :global(.ql-snow.ql-toolbar button svg *) {
        color: #ccc;
        stroke: #ccc;
    }
    :global(.ql-snow.ql-toolbar button:hover svg *) {
        stroke: white !important;
    }

    :global(.ql-active) {
        @apply !text-foreground !bg-foreground/20;
    }

    :global(.ql-active .ql-stroke) {
        stroke: white !important;
    }

    :global(.ql-picker-label) {
        @apply !border-0;
    }

    :global(.ql-picker-options) {
        @apply !bg-background !border !border-border rounded !p-4 !z-50;
        @apply text-muted-foreground;
    }

    :global(.ql-picker-item:hover, .ql-picker-item.ql-selected) {
        @apply !text-foreground;
    }

    :global(.ql-editor .mention) {
        @apply text-foreground font-medium;
    }

    :global(.ql-mention-list) {
        @apply bg-background font-sans py-2 rounded absolute z-50;
    }

    :global(.ql-mention-list-item) {
        @apply px-4 py-1 text-base truncate w-full sm:w-96;
    }

    :global(.ql-mention-list-item.selected) {
        @apply bg-secondary text-primary;
    }

    :global(.ql-tooltip) {
        @apply !bg-secondary !border-0 rounded !px-4 !py-2 font-sans !text-foreground/80 !shadow-none;
    }

    :global(.ql-tooltip input) {
        @apply !bg-foreground/10 !border-0 rounded !p-6 !text-foreground/80;
    }

    :global(.ql-editor a) {
        @apply !text-foreground;
    }

    :global(.ql-editor span.mention) {
        @apply text-primary;
    }

    :global(span.mention[data-id="npub1mygerccwqpzyh9pvp6pv44rskv40zutkfs38t0hqhkvnwlhagp6s3psn5p"]) {
        @apply text-pink-400;
    }
</style>
