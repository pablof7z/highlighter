<script lang="ts">
	import { Writable } from 'svelte/store';
	import { getContext } from "svelte";
	import { Editor } from "svelte-tiptap";
	import { DotsThreeVertical, ArrowArcLeft, ArrowArcRight, Link, ListBullets, ListNumbers, Quotes, TextB, TextItalic } from 'phosphor-svelte';
	import Image from './Toolbar/Image.svelte';
	import Heading from './Toolbar/Heading.svelte';
	import { openModal } from '$utils/modal';
	import LinkModal from './Toolbar/LinkModal.svelte';
	import { EditorView } from '.';
	import { Code } from 'lucide-svelte';
    import * as DropdownMenu from '$components/ui/dropdown-menu';
	import {Button} from '$components/ui/button';

    const editor = getContext('editorStore') as Writable<Editor>;
    const editorView = getContext('editorView') as Writable<EditorView>;

    function toggleEditorView() {
        if ($editorView === "wysiwyg") {
            editorView.set("raw");
        } else {
            editorView.set("wysiwyg");
        }
    }
    
    let listening = false;
        
    let undo = false;
    let redo = false;
    let bold = false;
    let italic = false;
    let blockquote = false;
    let bulletList = false;
    let orderedList = false;
    let link: string | boolean = false;
    
    $: if ($editor && !listening) {
        listening = true;
        const update = () => {
            undo = $editor.can().undo();
            redo = $editor.can().redo();
            bold = $editor.isActive('bold');
            italic = $editor.isActive('italic');
            blockquote = $editor.isActive('blockquote');
            bulletList = $editor.isActive('bulletList');
            orderedList = $editor.isActive('orderedList');
            link = $editor.getAttributes('link').href;
        }
        $editor.on("transaction", update);
        $editor.on("update", update);
    }

    function linkClick() {
        openModal(LinkModal, { editor: $editor, url: link });
    }
</script>

{#if $editor}
    <div class="flex flex-row items-center w-full justify-between">
        <div class="flex flex-row items-center divide-x divide-border editor-toolbar">
            <div class="button-group">
                <button on:click={() => $editor.chain().focus().undo().run()} disabled={!undo}>
                    <ArrowArcLeft size={18} weight="bold" />
                </button>
                <button on:click={() => $editor.chain().focus().redo().run()} disabled={!redo}>
                    <ArrowArcRight size={18} weight="bold" />
                </button>
            </div>

            <div class="button-group">
                <Heading editor={$editor} />
            </div>

            <div class="button-group">
                <button on:click={() => $editor.chain().focus().toggleBold().run()} class:active={bold}>
                    <TextB size={18} weight="bold" />
                </button>
                <button on:click={() => $editor.chain().focus().toggleItalic().run()} class:active={italic}>
                    <TextItalic size={18} weight="bold" />
                </button>
                <button on:click={() => $editor.chain().focus().toggleBlockquote().run()} class:active={blockquote}>
                    <Quotes size={18} weight="bold" />
                </button>
            </div>

            <div class="button-group">
                <Image editor={$editor} />
                <button on:click={linkClick} class:active={link}>
                    <Link size={18} weight="bold" />
                </button>
            </div>

            <div class="button-group">
                <button on:click={() => $editor.chain().focus().toggleBulletList().run()} class:active={bulletList}>
                    <ListBullets size={18} weight="bold" />
                </button>
                <button on:click={() => $editor.chain().focus().toggleOrderedList().run()} class:active={orderedList}>
                    <ListNumbers size={18} weight="bold" />
                </button>
            </div>

        </div>
        <div class="border-0">
            <DropdownMenu.Root>
                <DropdownMenu.Trigger>
                    <Button variant="ghost" class="w-10 h-10 p-0" size="icon">
                        <DotsThreeVertical size={18} weight="bold" />
                    </Button>
                </DropdownMenu.Trigger>
                <DropdownMenu.Content>
                    <DropdownMenu.Item on:click={toggleEditorView}>
                        <Code size={20} weight="bold" class="mr-3" />
                        {#if $editorView === "wysiwyg"}
                            Raw Editor
                        {:else}
                            Rich Editor
                        {/if}
                    </DropdownMenu.Item>
                    
                </DropdownMenu.Content>
            </DropdownMenu.Root>
        </div>
    </div>
{:else}
    no toolar
{/if}
