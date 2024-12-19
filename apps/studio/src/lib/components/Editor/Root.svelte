<script lang="ts">
	import { Editor, SvelteNodeViewRenderer } from 'svelte-tiptap';
	import { Markdown } from 'tiptap-markdown';
	import HardBreak from '@tiptap/extension-hard-break';
	import StarterKit from '@tiptap/starter-kit';
	import PubkeyExtension from './extensions/pubkey.svelte';
	import EventExtension from './extensions/event.svelte';
	import UploadImage from './extensions/upload-image.js';
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
	import NostrEntitySearchModal from '@components/NostrEntitySearchModal.svelte';
	import Toolbar from './Toolbar.svelte';
	import type { Extension } from '@tiptap/core';
	import { Uploader } from '@highlighter/common';
	import { ndk } from '@/state/ndk';
	import { appState } from '@/state/app.svelte';

	type Props = {
		content: string;
		placeholder?: string;
		skipToolbar?: boolean;
		editor?: Editor;
		toolbarClass?: string;
		className?: string;
		showMentions?: boolean;
		markdown?: boolean;
		readonly?: boolean;
		newline?: boolean;

		onEnter?: () => void;
		onFocus?: () => void;
		onKeyDown?: (editor: Editor, event: KeyboardEvent) => void;
	};

	let {
		content = $bindable(),
		placeholder = 'Write...',
		skipToolbar = false,
		editor = $bindable(),
		toolbarClass = '',
		className = '',
		markdown = true,
		showMentions = $bindable(false),
		readonly = false,
		newline = true,
		onEnter,
		onKeyDown,
		onFocus
	}: Props = $props();

	let editorElement = $state<HTMLDivElement | null>(null);

	onMount(() => {
		if (!editorElement || editor) return;

		const extensions: Extension[] = [];

		if (markdown) {
			extensions.push(Markdown.configure({ tightLists: true }));
		} else {
			extensions.push(
				HardBreak.configure({
					keepMarks: true,
					keepAttributes: false
				})
			);
		}

		editor = new Editor({
			element: editorElement,
			extensions: [
				StarterKit,
				...extensions,
				Dropcursor,
				Strike,
				BulletList,
				TipTapImage.configure({
					allowBase64: true
				}),
				UploadImage.configure({
					uploadFn: (blob) => {
						return new Promise((resolve, reject) => {
							const uploader = new Uploader(blob, appState.activeBlossomServer, ndk);
							uploader.onUploaded = (url: string) => {
								resolve(url);
							};
							uploader.onError = (error: Error) => {
								reject(error.message);
							};
							uploader.start();
						});
					}
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
				Table,
				TableRow,
				TableHeader,
				TableCell
			],
			editable: !readonly,
			onUpdate: () => {
				if (markdown) {
					content = editor?.storage.markdown.getMarkdown();
					console.log('setting content cache', content);
					contentCache = content;
				} else {
					// get as simple text
					// need to hack this because tiptap is adding two newlines for some reason
					let text = editor?.getText();
					console.log('text', JSON.stringify(text));
					if (text?.match(/\n\n/)) {
						console.log('replacing newlines', text);
						content = text.replace(/\n\n/g, '\n');
					} else {
						content = text ?? '';
					}
					console.log('setting content cache', content);
					contentCache = content;
				}
			},
			onFocus: () => onFocus?.(),
			editorProps: {
				handleKeyDown: (_, event) => {
					onKeyDown?.(_, event);
					if (!markdown && event.key === 'Enter') {
						event.preventDefault();
						onEnter?.();
						// editor?.commands.setHardBreak();
					} else if (event.key === '@') {
						event.preventDefault();
						setTimeout(() => (showMentions = true), 0);
					}
				}
			}
		});
	});

	let contentCache = $state('');

	$effect(() => {
		if (!editor) return;
		if (!newline && content.match(/\n/)) {
			content = content.replace(/\n/g, '');
		}

		if (contentCache !== content) {
			contentCache = content;

			editor.commands.setEventContent({
				content: content,
				kind: markdown ? 30023 : 1,
				tags: []
			});
		}
	});
</script>

{#if editor && !skipToolbar}
	<Toolbar {editor} class={toolbarClass} />
{/if}

<div class="flex h-full w-full grow {className}" bind:this={editorElement}></div>

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
