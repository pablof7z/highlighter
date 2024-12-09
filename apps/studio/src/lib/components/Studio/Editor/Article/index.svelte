<script lang="ts">
	import * as Editor from '@components/Editor';

	let { editorState = $bindable() } = $props();
</script>

<div class="mx-auto flex h-full w-full max-w-3xl flex-col items-stretch justify-stretch p-4">
	<div class="min-h-12 text-4xl font-bold">
		<Editor.Root bind:content={editorState.title} placeholder="Title" />
	</div>

	<div class="min-h-12 text-lg font-light">
		<Editor.Root bind:content={editorState.summary} placeholder="Add a subtitle..." />
	</div>

	<div class="text-muted-foreground article min-h-[70vh]">
		<Editor.Root bind:content={editorState.content} />
	</div>
</div>
