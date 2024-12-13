<script lang="ts">
	import * as Editor from '@components/Editor';
	import type { Editor as EditorType } from 'svelte-tiptap';
	import CoverImage from './buttons/CoverImage.svelte';
	import { type ArticleState } from '@components/Post/state/article.svelte';

	type Props = {
		postState: ArticleState;
	}
	
	let { postState = $bindable() }: Props = $props();

	let showMentions = $state(false);

	function onMention() {
		showMentions = true;
	}

	let summary = $state<EditorType | undefined>(undefined);

	let editor = $state<EditorType | undefined>(undefined);
</script>

<div class="mx-auto flex h-full w-full max-w-3xl flex-col items-stretch justify-stretch p-4">
	{#if editor}
		<div class="bg-background sticky top-12 z-50 mb-4">
			<Editor.Toolbar editor={editor} class="bg-background" onMention={onMention} />
		</div>
	{/if}

	{#if postState.image}
		<CoverImage
			bind:postState
			class="w-full h-full max-h-[24vh] overflow-clip"
			imgProps={{ class: 'w-full h-full object-cover'}}
		/>
	{/if}

	<div class="min-h-12 !text-4xl font-bold article--title">
		<Editor.Root
			bind:content={postState.title}
			placeholder="Title"
			skipToolbar={true}
			markdown={false}
			newline={false}
			onEnter={() => summary?.commands.focus()}
		/>
	</div>

	<div class="min-h-12 text-lg font-light">
		<Editor.Root
			bind:editor={summary}
			bind:content={postState.summary}
			placeholder="Add a subtitle..."
			markdown={false}
			skipToolbar={true}
			newline={false}
			onEnter={() => editor?.commands.focus()}
		/>
	</div>

	<div class="text-muted-foreground article min-h-[70vh] w-full">
		<Editor.Root
			bind:content={postState.content}
			bind:editor
			skipToolbar={true}
			bind:showMentions
		/>
	</div>
</div>
