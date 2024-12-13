<script lang="ts">
    import { Undo, Redo, Bold, Italic, Quote, Strikethrough, Link, ListOrdered, AtSign } from 'lucide-svelte';
	// import Image from './Toolbar/Image.svelte';
	// import Heading from './Toolbar/Heading.svelte';
	// import { openModal } from '$utils/modal';
	// import LinkModal from './Toolbar/LinkModal.svelte';
	// import { Code } from 'lucide-svelte';
    import * as DropdownMenu from '@components/ui/dropdown-menu';
	import {Button} from '@components/ui/button';
	import { NDKUser } from '@nostr-dev-kit/ndk';
	import { ListBullet } from 'svelte-radix';
	import type { Editor } from 'svelte-tiptap';

    type Props = {
        editor: Editor;
        class: string;
        onMention?: () => void;
    }
    
    const { editor, class: className = "", onMention }: Props = $props();

    let listening = false;
        
    let undo = $state(false);
    let redo = $state(false);
    let bold = $state(false);
    let italic = $state(false);
    let strike = $state(false);
    let blockquote = $state(false);
    let bulletList = $state(false);
    let orderedList = $state(false);
    let link: string | boolean = $state(false);
    
    if (editor && !listening) {
        listening = true;
        const update = () => {
            undo = editor.can().undo();
            redo = editor.can().redo();
            bold = editor.isActive('bold');
            italic = editor.isActive('italic');
            strike = editor.isActive('strike');
            blockquote = editor.isActive('blockquote');
            bulletList = editor.isActive('bulletList');
            orderedList = editor.isActive('orderedList');
            link = editor.getAttributes('link').href;
        }
        editor.on("transaction", update);
        editor.on("update", update);
    }

    function linkClick() {
        // openModal(LinkModal, { editor: editor, url: link });
    }

    function mentionPicker() {
        onMention?.();
    }
</script>

<div class="flex flex-row items-center w-full justify-between {className}">
    <div class="flex flex-row items-center divide-x divide-border editor-toolbar">
        <div class="button-group">
            <button onclick={() => editor.chain().focus().undo().run()} disabled={!undo}>
                <Undo size={18} weight="bold" />
            </button>
            <button onclick={() => editor.chain().focus().redo().run()} disabled={!redo}>
                <Redo size={18} weight="bold" />
            </button>
        </div>

        <!-- <div class="button-group">
            <Heading editor={editor} />
        </div> -->

        <div class="button-group">
            <button onclick={() => editor.chain().focus().toggleBold().run()} class:active={bold}>
                <Bold size={18} weight="bold" />
            </button>
            <button onclick={() => editor.chain().focus().toggleItalic().run()} class:active={italic}>
                <Italic size={18} weight="bold" />
            </button>
            <button onclick={() => editor.chain().focus().toggleBlockquote().run()} class:active={blockquote}>
                <Quote size={18} />
            </button>
            <button onclick={() => editor.chain().focus().toggleStrike().run()} class:active={strike}>
                <Strikethrough size={18} weight="bold" />
            </button>
        </div>

        <div class="button-group">
            <!-- <Image editor={editor} /> -->
            <button onclick={mentionPicker}>
                <AtSign size={18} weight="bold" />
            </button>
            <button onclick={linkClick} class:active={link}>
                <Link size={18} weight="bold" />
            </button>
        </div>

        <div class="button-group">
            <button onclick={() => editor.chain().focus().toggleBulletList().run()} class:active={bulletList}>
                <ListBullet size={18} weight="bold" />
            </button>
            <button onclick={() => editor.chain().focus().toggleOrderedList().run()} class:active={orderedList}>
                <ListOrdered size={18} weight="bold" />
            </button>
        </div>

    </div>
</div>


<style lang="postcss">
    .editor-toolbar button {
        @apply flex h-10 w-10 cursor-pointer items-center justify-center rounded-sm p-2 hover:bg-secondary hover:text-secondary-foreground text-muted-foreground;
    }

    .editor-toolbar button[disabled] {
        cursor: not-allowed;
        opacity: 0.2;
    }

    .editor-toolbar .button-group {
        @apply flex flex-row items-center px-2;
    }

    .editor-toolbar .active {
        @apply bg-secondary text-secondary-foreground;
    }
</style>