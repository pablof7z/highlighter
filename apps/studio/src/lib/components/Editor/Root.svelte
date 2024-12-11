<script lang="ts">
	import { Editor, SvelteNodeViewRenderer } from 'svelte-tiptap';
	import { Markdown } from 'tiptap-markdown';
	import StarterKit from '@tiptap/starter-kit';
	import PubkeyExtension from './extensions/pubkey.svelte';
	import EventExtension from './extensions/event.svelte';
	import { NostrExtension } from 'nostr-editor';
	import BulletList from '@tiptap/extension-bullet-list';
	import Strike from '@tiptap/extension-strike';
	import Dropcursor from '@tiptap/extension-dropcursor';
	import Placeholder from '@tiptap/extension-placeholder';
	import Blockquote from '@tiptap/extension-blockquote';
	import { Image as TipTapImage } from '@tiptap/extension-image';
	import Heading from '@tiptap/extension-heading';
	import { nip19 } from 'nostr-tools';
	import Table from '@tiptap/extension-table';
	import TableCell from '@tiptap/extension-table-cell';
	import TableHeader from '@tiptap/extension-table-header';
	import TableRow from '@tiptap/extension-table-row';
	import { onMount } from 'svelte';
	import NostrEntitySearchModal from '../Studio/NostrEntitySearchModal.svelte';
	import Toolbar from './Toolbar.svelte';

	let {
		content = $bindable(),
		placeholder = 'Write...',
		editorState = $bindable(),
		skipToolbar = false,
		editor = $bindable(),
		toolbarClass = ''
	} = $props();

	let editorElement = $state<HTMLDivElement | null>(null);
	let showMentions = $state(false);

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
				NostrExtension.configure({
					extend: {
						nprofile: { addNodeView: () => SvelteNodeViewRenderer(PubkeyExtension) },
						naddr: { addNodeView: () => SvelteNodeViewRenderer(EventExtension) },
						nevent: { addNodeView: () => SvelteNodeViewRenderer(EventExtension) },
						link: { autolink: true }
					}
				}),
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
			},
			editorProps: {
				handleKeyDown: (_, event) => {
					if (event.key === '@') {
						event.preventDefault();
						setTimeout(() => (showMentions = true), 0);
					}
				}
			}
		});

		editor.commands.focus('end');
	});
</script>

{#if !skipToolbar}
	<Toolbar {editor} class={toolbarClass} />
{/if}

<div class="flex h-full w-full grow" bind:this={editorElement}></div>

<NostrEntitySearchModal
	bind:open={showMentions}
	onSelect={(nip19encoding: string) => {
		try {
			const res = nip19.decode(nip19encoding);
			if (res.type === 'npub' || res.type === 'nprofile') {
				editor?.commands.insertNProfile({ nprofile: `nostr:${nip19encoding}` });
			} else if (['note', 'nevent'].includes(res.type)) {
				editor?.commands.insertNEvent({ nevent: `nostr:${nip19encoding}` });
			} else if (res.type === 'naddr') {
				editor?.commands.insertNAddr({ naddr: `nostr:${nip19encoding}` });
			}

			editor?.commands.focus();
		} catch (e) {
			console.error(e);
		}
	}}
	onClose={() => {
		editor?.commands.focus();
	}}
/>
