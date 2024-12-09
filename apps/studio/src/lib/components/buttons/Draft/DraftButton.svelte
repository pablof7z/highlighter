<script lang="ts">
	import { ndk } from '@/state/ndk';
	import type { EditorState } from '@/components/Studio/state.svelte';
	import { NDKDraft } from '@nostr-dev-kit/ndk';

	let { editorState = $bindable() } = $props();

	let status = $state<'unsaved' | 'saving' | 'saved' | 'error'>('unsaved');

	function clicked() {
		if (!editorState.content) {
			console.error('No draft to save');
			return;
		}

		editorState.draft ??= new NDKDraft(ndk);

		const event = editorState.generateEvent();
		editorState.draft.event = event;
		status = 'saving';
		editorState.draft
			.save({ publish: true })
			.then(() => (status = 'saved'))
			.catch((e) => {
				console.error(e);
				status = 'error';
			});
	}
</script>

<button onclick={clicked} class="text-muted-foreground flex items-center gap-2 text-sm font-light">
	{#if status === 'saved'}
		<div class="h-2 w-2 rounded-full bg-green-500"></div>
	{:else if status === 'saving'}
		<div class="h-2 w-2 rounded-full bg-yellow-500"></div>
	{:else if status === 'error'}
		<div class="h-2 w-2 rounded-full bg-red-500"></div>
	{:else}
		<div class="h-2 w-2 rounded-full bg-gray-500"></div>
	{/if}

	{status}
</button>
