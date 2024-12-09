<script lang="ts">
	import { Editor, SvelteNodeViewRenderer } from 'svelte-tiptap';
	import { Markdown } from 'tiptap-markdown';
	import StarterKit from '@tiptap/starter-kit';
	import BulletList from '@tiptap/extension-bullet-list';
	import Strike from '@tiptap/extension-strike';
	import Dropcursor from '@tiptap/extension-dropcursor';
	import Placeholder from '@tiptap/extension-placeholder';
	import Blockquote from '@tiptap/extension-blockquote';
	import { Image as TipTapImage } from '@tiptap/extension-image';
	import Heading from '@tiptap/extension-heading';
	import Mention from '@tiptap/extension-mention';
	import Table from '@tiptap/extension-table';
	import TableCell from '@tiptap/extension-table-cell';
	import TableHeader from '@tiptap/extension-table-header';
	import TableRow from '@tiptap/extension-table-row';
	import { onMount } from 'svelte';

	let { content = $bindable(), placeholder = 'Write...' } = $props();

	let editor = $state<Editor | null>(null);
	let editorElement = $state<HTMLDivElement | null>(null);

	onMount(() => {
		if (!editorElement || editor) return;

		editor = new Editor({
			element: editorElement,
			extensions: [
				StarterKit,
				Markdown.configure({
					tightLists: true
				}),
				Dropcursor,
				Strike,
				BulletList,
				TipTapImage.configure({
					allowBase64: true
				}),
				Placeholder.configure({
					placeholder,
					emptyEditorClass:
						'cursor-text before:content-[attr(data-placeholder)] before:absolute before:text-muted-foreground/50 before-pointer-events-none'
				}),
				Blockquote,
				// NostrExtension.configure({
				// 	extend: {
				// 		nprofile: { addNodeView: () => SvelteNodeViewRenderer(PubkeyExtension) },
				// 		nevent: { addNodeView: () => SvelteNodeViewRenderer(NeventExtension) },
				// 		naddr: { addNodeView: () => SvelteNodeViewRenderer(NaddrExtension) },
				// 		link: { autolink: true }
				// 	}
				// }),
				Heading.configure({
					levels: [1, 2, 3, 4, 5, 6]
				}),
				// UploadImage.configure({
				// 	uploadFn: (blob) => {
				// 		return new Promise((resolve, reject) => {
				// 			const uploader = new Uploader(blob, $activeBlossomServer);
				// 			uploader.onUploaded = (url: string) => {
				// 				resolve(url);
				// 			};
				// 			uploader.onError = (error: Error) => {
				// 				reject(error.message);
				// 			};
				// 			uploader.start();
				// 		});
				// 	}
				// }),
				// Link.configure({
				//     openOnClick: false,
				//     autolink: true,
				//     defaultProtocol: 'https',
				// }),
				// Mention.configure({
				// 	suggestion: suggestion()
				// }),
				Table,
				TableRow,
				TableHeader,
				TableCell
			],
			content,
			onUpdate: () => {
				content = editor?.storage.markdown.getMarkdown();
			}
		});

		editor.commands.focus('end');

		editor.on('update', () => {
			console.log(editor.getHTML());
		});
	});
</script>

<div class="flex h-full w-full grow" bind:this={editorElement}></div>
