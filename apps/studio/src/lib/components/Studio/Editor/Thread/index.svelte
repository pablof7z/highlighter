<script lang="ts">
	import * as Editor from '@components/Editor';

	let { editorState = $bindable() } = $props();

	let showMentions = $state(false);

    editorState.content = 'hi';
</script>

<div class="mx-auto flex h-full w-full max-w-3xl flex-col items-stretch justify-stretch p-4">
	<div class="text-muted-foreground min-h-[70vh] w-full">
		<Editor.Root
			bind:content={editorState.content}
			bind:editor={editorState.editor}
			bind:showMentions
            skipToolbar={true}
		/>
        <div class="text-xs text-muted-foreground">
            Shift+Enter to add to this thread
        </div>
	</div>
</div>
