<script lang="ts">
	import { getContext } from "svelte";
	import { Editor } from "svelte-tiptap";
	import { Writable } from "svelte/store";
	import { EditorView } from ".";

    const editorElement = getContext('editorElement') as Writable<HTMLDivElement | null>;
	export let content: string = "";

	const editor = getContext('editorStore') as Writable<Editor | null>;
	const editorView = getContext('editorView') as Writable<EditorView>;

	let markdown: string = "";

	$: markdown = content;

	function updateRawContent(event: Event) {
		if (!$editor) return;
		const textarea = event.target as HTMLTextAreaElement;
		$editor.commands.setContent(textarea.value);
		content = textarea.value;
	}
</script>

<div class:hidden={$editorView !== "wysiwyg"} class="h-full w-full min-h-[10rem] flex items-stretch break-words overflow-x-auto {$$props.class??""}" bind:this={$editorElement} />

<div class:hidden={$editorView !== "raw"} class="flex flex-col gap-2">
	<textarea bind:value={markdown} on:change={updateRawContent} />
	<div class="text-xs text-muted-foreground/50">
		Use <span class="text-foreground">markdown</span> or <span class="text-foreground">HTML</span> to format your content.
	</div>
</div>

<style lang="postcss">
	textarea {
		@apply bg-transparent h-full w-full min-h-[10rem] flex items-stretch break-words overflow-x-auto resize-none;
		@apply min-h-[calc(100dvh-30rem-50px)] border border-border rounded-md p-2;
	}
</style>