<script lang="ts">
	import { Writable } from 'svelte/store';
	import { getContext } from "svelte";
	import { Editor } from "svelte-tiptap";
	import { ArrowArcLeft, ArrowArcRight, ListBullets, ListNumbers, TextB, TextItalic } from 'phosphor-svelte';
	import Image from './Toolbar/Image.svelte';

    const editor = getContext('editorStore') as Writable<Editor>;
    
    let listening = false;
        
    let undo = false;
    let redo = false;
    let bold = false;
    let italic = false;
    
    $: if ($editor && !listening) {
        listening = true;
        const update = () => {
            undo = $editor.can().undo();
            redo = $editor.can().redo();
            bold = $editor.isActive('bold');
            italic = $editor.isActive('italic');
        }
        $editor.on("transaction", update);
        $editor.on("update", update);
    }

    function addImage() {
        const url = prompt('Enter the URL of the image:');
        if (!url) return;
        $editor.chain().focus().setImage({ src: url }).run();
    }
</script>

{#if $editor}
    <div class="flex flex-row items-center divide-x divide-border">
        <div class="button-group">
            <button on:click={() => $editor.chain().focus().undo().run()} disabled={!undo}>
                <ArrowArcLeft size={18} weight="bold" />
            </button>
            <button on:click={() => $editor.chain().focus().redo().run()} disabled={!redo}>
                <ArrowArcRight size={18} weight="bold" />
            </button>
        </div>

        <div class="button-group">
            <button on:click={() => $editor.chain().focus().toggleBold().run()} class:active={bold}>
                <TextB size={18} weight="bold" />
            </button>
            <button on:click={() => $editor.chain().focus().toggleItalic().run()} class:active={italic}>
                <TextItalic size={18} weight="bold" />
            </button>
        </div>

        <div class="button-group">
            <Image editor={$editor} />
        </div>

        <div class="button-group">
            <button on:click={() => $editor.chain().focus().toggleBulletList().run()} class:active={bold}>
                <ListBullets size={18} weight="bold" />
            </button>
            <button on:click={() => $editor.chain().focus().toggleOrderedList().run()} class:active={bold}>
                <ListNumbers size={18} weight="bold" />
            </button>
        </div>


    </div>
{:else}
    no toolar
{/if}

<style lang="postcss">
    button {
        @apply p-2 flex items-center justify-center w-10 h-10 cursor-pointer hover:bg-secondary hover:text-secondary-foreground rounded-sm;
    }
    
    button[disabled] {
        cursor: not-allowed;
        opacity: 0.2;
    }

    .button-group {
        @apply px-2 flex flex-row items-center;
    }

    .active {
        @apply bg-secondary text-secondary-foreground;
    }
</style>