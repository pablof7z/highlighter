<script lang="ts">
	import Article from './Article/index.svelte';
	import Toolbar from './Toolbar.svelte';
	import BottomToolbar from './BottomToolbar.svelte';
	import FinalizeModal from './Finalize/Modal.svelte';
	import SettingsModal from '../Settings/Modal.svelte';
	import HistoryModal from './History/Modal.svelte';
	import { appState } from '@/state/app.svelte';
	import type { NDKDraft, NDKEvent } from '@nostr-dev-kit/ndk';
	import { goto, replaceState } from '$app/navigation';

	let { editorState = $bindable() } = $props();

	let settingsOpen = $state(false);
	let finalizeOpen = $state(false);
	let historyOpen = $state(false);

	function onPublish(event: NDKEvent) {
		appState.activeEvent = event;
		goto('/share');
	}

	let hasDraft = $state(false);

	function onSaveDraft(draft: NDKDraft) {
		if (!hasDraft) {
			hasDraft = true;
			replaceState('/editor/article/' + draft.encode(), {});
		}
	}
</script>

<div class="flex-col">
	<div class="w-full px-4 py-2 sticky top-0 bg-background z-40">
		<Toolbar
			{editorState}
			onContinue={() => (finalizeOpen = true)}
			onSaveDraft={onSaveDraft}
		/>
	</div>

	{#if editorState.type === 'article'}
		<Article bind:editorState />
	{:else}
		Unhandled event type
	{/if}
</div>

<div class="fixed bottom-0 left-0 right-0 flex flex-row justify-between px-4 py-2">
	<BottomToolbar
		{editorState}
		onOpenHistory={() => { historyOpen = true; }}
		onOpenSettings={() => { settingsOpen = true; }} />
</div>

<SettingsModal bind:editorState bind:open={settingsOpen} />
<FinalizeModal bind:editorState bind:open={finalizeOpen}
	onSuccess={onPublish}
/>

<HistoryModal {editorState} bind:open={historyOpen} />
