<script lang="ts">
	import {
		Undo,
		Redo,
		Bold,
		Italic,
		Quote,
		Strikethrough,
		Link,
		ListOrdered,
		AtSign,
		Code
	} from 'lucide-svelte';
	import Image from './Toolbar/Image.svelte';
	import Heading from './Toolbar/Heading.svelte';
	// import { openModal } from '$utils/modal';
	// import LinkModal from './Toolbar/LinkModal.svelte';
	import * as DropdownMenu from '@components/ui/dropdown-menu';
	import { Button } from '@components/ui/button';
	import { NDKUser } from '@nostr-dev-kit/ndk';
	import { ListBullet } from 'svelte-radix';
	import type { Editor } from 'svelte-tiptap';
	import * as Tooltip from '@components/ui/tooltip';

	type Props = {
		editor: Editor;
		class: string;
		onMention?: () => void;
		onToggleRaw?: () => void;
	};

	const { editor, class: className = '', onMention, onToggleRaw }: Props = $props();

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
		};
		editor.on('transaction', update);
		editor.on('update', update);
	}

	function linkClick() {
		// openModal(LinkModal, { editor: editor, url: link });
	}

	function mentionPicker() {
		onMention?.();
	}
</script>

<div class="flex w-full flex-row items-center justify-between {className}">
	<div class="divide-border editor-toolbar flex flex-row items-center divide-x">
		<div class="button-group">
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().undo().run()} disabled={!undo}>
							<Undo size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Undo</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().redo().run()} disabled={!redo}>
							<Redo size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Redo</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
		</div>

		<div class="button-group">
            <Heading editor={editor} />
        </div>

		<div class="button-group">
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().toggleBold().run()} class:active={bold}>
							<Bold size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Bold</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().toggleItalic().run()} class:active={italic}>
							<Italic size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Italic</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().toggleBlockquote().run()} class:active={blockquote}>
							<Quote size={18} />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Blockquote</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().toggleStrike().run()} class:active={strike}>
							<Strikethrough size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Strikethrough</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
		</div>

		<div class="button-group">
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<Image {editor} />
					</Tooltip.Trigger>
					<Tooltip.Content>Image</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={mentionPicker}>
							<AtSign size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Mention people or content in nostr</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={linkClick} class:active={link}>
							<Link size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Link</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
		</div>

		<div class="button-group">
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().toggleBulletList().run()} class:active={bulletList}>
							<ListBullet size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Bullet List</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
			<Tooltip.Provider>
				<Tooltip.Root delayDuration={0}>
					<Tooltip.Trigger>
						<button onclick={() => editor.chain().focus().toggleOrderedList().run()} class:active={orderedList}>
							<ListOrdered size={18} weight="bold" />
						</button>
					</Tooltip.Trigger>
					<Tooltip.Content>Ordered List</Tooltip.Content>
				</Tooltip.Root>
			</Tooltip.Provider>
		</div>

		{#if onToggleRaw}
			<div class="button-group">
				<Tooltip.Provider>
					<Tooltip.Root delayDuration={0}>
						<Tooltip.Trigger>
							<button onclick={onToggleRaw}>
								<Code size={18} weight="bold" />
							</button>
						</Tooltip.Trigger>
						<Tooltip.Content>Toggle raw editor</Tooltip.Content>
					</Tooltip.Root>
				</Tooltip.Provider>
			</div>
		{/if}
	</div>
</div>

<style lang="postcss">
	.editor-toolbar .button-group {
		@apply flex flex-row items-center px-2;
	}

	.editor-toolbar .active {
		@apply bg-secondary text-secondary-foreground;
	}
</style>
