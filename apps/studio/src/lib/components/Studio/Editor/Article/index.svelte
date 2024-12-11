<script lang="ts">
	import * as Editor from '@components/Editor';
	import CoverImage from '../buttons/CoverImage.svelte';

	let { editorState = $bindable() } = $props();

	let editor = $state<null>(null);
</script>

<div class="mx-auto flex h-full w-full max-w-3xl flex-col items-stretch justify-stretch p-4">
	{#if editor}
		<div class="bg-background sticky top-12 z-50 mb-4">
			<Editor.Toolbar {editor} />
		</div>
	{/if}

	{#if editorState.image}
		<CoverImage
			{editorState}
			class="w-full h-full max-h-[24vh] overflow-clip"
			imgProps={{ class: 'w-full h-full object-cover'}}
		/>
	{/if}

	<div class="min-h-12 text-4xl font-bold">
		<Editor.Root bind:content={editorState.title} placeholder="Title" skipToolbar={true} />
	</div>

	<div class="min-h-12 text-lg font-light">
		<Editor.Root
			bind:content={editorState.summary}
			placeholder="Add a subtitle..."
			skipToolbar={true}
		/>
	</div>

	<div class="text-muted-foreground article min-h-[70vh] w-full">
		<Editor.Root bind:content={editorState.content} bind:editor skipToolbar={true} />
	</div>
</div>
