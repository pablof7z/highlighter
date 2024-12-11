<script lang="ts">
	import Article from './Article/index.svelte';
	import Toolbar from './Toolbar.svelte';
	import BottomToolbar from './BottomToolbar.svelte';
	import FinalizeModal from './Finalize/Modal.svelte';
	import SettingsModal from '../Settings/Modal.svelte';
	import SuccessModal from './Success/Modal.svelte';

	let { editorState = $bindable() } = $props();

	let settingsOpen = $state(false);
	let finalizeOpen = $state(false);
	let successOpen = $state(true);

	function onPublish() {
		successOpen = true;
	}
</script>

<div class="flex-col">
	<div class="w-full px-4 py-2 sticky top-0 bg-background z-40">
		<Toolbar bind:editorState onContinue={() => (finalizeOpen = true)} />
	</div>

	{#if editorState.type === 'article'}
		<Article bind:editorState />
	{:else}
		Unhandled event type
	{/if}
</div>

<div class="fixed bottom-0 left-0 right-0 flex flex-row justify-between px-4 py-2">
	<BottomToolbar onOpenSettings={() => { settingsOpen = true; }} />
</div>

<SettingsModal bind:editorState bind:open={settingsOpen} />
<FinalizeModal bind:editorState bind:open={finalizeOpen}
	onSuccess={onPublish}
/>

<SuccessModal bind:editorState bind:open={successOpen}/>

