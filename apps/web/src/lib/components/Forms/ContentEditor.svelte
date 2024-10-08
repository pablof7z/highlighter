<script lang="ts">
	import { NDKArticle, NDKTag } from "@nostr-dev-kit/ndk";
    import { createEventDispatcher, onMount } from "svelte";
    import QuillMarkdown from 'quilljs-markdown';
    import quillEditorMention from "./quill-editor-mention.js";
	import { getContents } from './quill-editor-contents.js';
	import { Image } from 'phosphor-svelte';
	import { EventContent, prettifyNip05 } from '@nostr-dev-kit/ndk-svelte-components';
	import { wysiwygEditor } from '$stores/settings.js';
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import Checkbox from "./Checkbox.svelte";
	import { ndk } from "$stores/ndk.js";
	import { toast } from "svelte-sonner";
	import { isMobileBuild } from "$utils/view/mobile.js";
    import * as Tooltip from "$lib/components/ui/tooltip";
    import { EmbedBlot } from 'parchment';

    export let content: string = "";
    export let placeholder = "Write your heart out...";
    export let toolbar = true;
    export let autofocus = false;
    export let allowMarkdown = true;
    export let enterSubmits = false;
    export let forceWywsiwyg = !toolbar;

    console.trace('content-editor')

    const dispatch = createEventDispatcher();

    let editorEl: HTMLElement;
    let toolbarEl: HTMLElement;

    let quill: any;

    let uploadBlob: Blob;

    class SoftBreak extends EmbedBlot {
        static create(value) {
            let node = super.create(value);
            return node;
        }

        length() {
            return 2;
        }

        value() {
            return '\n\n';
        }

        static value(node) {
            return '\n\n';
        }

        static blotName = 'softbreak';
        static tagName = 'BR';
    }

    async function enableEditor() {
        const {default: Quill} = await import('quill');
        const {Mention, MentionBlot} = await import('quill-mention');
        const { default: QuillImageDropAndPaste } = await import ('quill-image-drop-and-paste');

        Quill.register({ "blots/mention": MentionBlot, "modules/mention": Mention });
        // check if Quill already has modules/mention
        if (!isMobileBuild()) await import('quill-paste-smart');
        if (!Quill.imports['modules/imageDropAndPaste']) Quill.register('modules/imageDropAndPaste', QuillImageDropAndPaste);

        Quill.register(SoftBreak);

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
                        linebreak: { 
                            key: 'Enter',
                            shiftKey: true,
                            handler: function(range, context) {
                                const quill = this.quill;
                                const currentLength = quill.getLength();
        
                                quill.insertEmbed(range.index, 'softbreak', '');
                                quill.setSelection(Math.min(range.index + 2, currentLength), Quill.sources.SILENT);
                            }
                        },
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

        // if (!allowMarkdown) options.formats = ['modules/mention'];

        
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

    $: if (!quill && editorEl && ($wysiwygEditor || forceWywsiwyg)) {
        enableEditor();
    }
    
    // onMount(async () => {
    //     if ($wysiwygEditor || forceWywsiwyg) enableEditor();
    // })

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
            toast.error("Failed to upload image");
        }
    }

    function toggleEditor() {
        if ($wysiwygEditor && editorEl) {
            enableEditor();
        } else {
        }
    }
</script>

<div class="flex flex-col border-none sm:rounded-xl border grow">
    {#if toolbar}
        <div class="flex flex-row justify-between font-sans gap-6 toolbar sticky z-40 top-[var(--header-height)] border-y border-border mobile-nav items-center mb-4">
            <div bind:this={toolbarEl} class="toolbar-container w-full">
                {#if $wysiwygEditor || forceWywsiwyg}
                    <span class="ql-formats">
                        <select class="ql-header"></select>
                    </span>
                    <span class="ql-formats flex flex-row flex-none">
                        <button class="ql-list" value="ordered" />
                        <button class="ql-list" value="bullet" />
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

            <!-- <Tooltip.Root>
                <Tooltip.Trigger>
                    <Checkbox
                        class="border-none text-muted-foreground text-sm max-sm:hidden py-4"
                        type="switch"
                        bind:value={$wysiwygEditor}
                        on:change={toggleEditor}
                    >
                        WYSIWYG
                    </Checkbox>
                </Tooltip.Trigger>
                <Tooltip.Content>
                    Toggle the WYSIWYG editor
                </Tooltip.Content>
            </Tooltip.Root> -->
        </div>
    {/if}
    {#if $$slots.belowToolbar}
        <slot name="belowToolbar" />
    {/if}
    <div class="pt-0 flex flex-col gap-4 transition-all duration-100 {$$props.class??""}">
        {#if $wysiwygEditor || forceWywsiwyg}
            <div bind:this={editorEl} class="
                editor h-full {$$props.class??""}
            " style={$$props.style??""}>
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
                style={$$props.style??""}
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
        @apply flex flex-row items-center gap-1;
    }

    :global(.ql-editor.ql-blank::before) {
        @apply text-muted-foreground right-0 left-0;
        font-style: normal;
    }

    :global(.ql-editor) {
        @apply !p-0 grow focus:!ring-0 focus:!outline-0 focus-visible:!outline-none !border-0;
    }

    :global(.ql-container) {
    }

    :global(.toolbar) {
        @apply flex-none;
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

    :global(.ql-editor) {
        @apply !p-0;
    }
    
    :global(.ql-editor .mention) {
        @apply text-foreground font-medium;
    }
    
    :global(.ql-snow.ql-toolbar button, .ql-snow .ql-toolbar button) {
        float: none !important;
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