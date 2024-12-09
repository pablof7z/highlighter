<script lang="ts">
	import Article from './Article/index.svelte';
	import Toolbar from './Toolbar.svelte';
	import BottomToolbar from './BottomToolbar.svelte';
	import * as Dialog from '@/components/ui/dialog';
	import Settings from '../Settings.svelte';
	import { Button } from '@/components/ui/button';

	let { editorState = $bindable() } = $props();

	let showModal = $state<boolean | 'publish' | 'settings'>('publish');
</script>

<div class="flex-col">
	<div class="w-full px-4 py-2">
		<Toolbar bind:editorState onContinue={() => (showModal = 'publish')} />
	</div>
	{#if editorState.type === 'article'}
		<Article bind:editorState />
	{:else}
		Unhandled event type
	{/if}
</div>

<div class="fixed bottom-0 left-0 right-0 flex flex-row justify-between px-4 py-2">
	<BottomToolbar onOpenSettings={() => (showModal = 'settings')} />
</div>

{#if showModal}
	<Dialog.Root open={true} onOpenChange={() => (showModal = false)}>
		{#if showModal === 'settings'}
			<Dialog.Content
				class="overflow-hidden p-0 md:max-h-[500px] md:max-w-[700px] lg:max-w-[800px]"
			>
				<Dialog.Title class="sr-only">Settings</Dialog.Title>
				<Dialog.Description class="sr-only">Customize your settings here.</Dialog.Description>

				<Settings bind:editorState />
			</Dialog.Content>
		{:else if showModal === 'publish'}
			<Dialog.Content>
				<Dialog.Title>Ready to publish?</Dialog.Title>
				<Dialog.Description class="sr-only">Publish your content here.</Dialog.Description>

				<Dialog.Footer>
					<Button variant="link" onclick={() => (showModal = 'settings')}>Advanced</Button>
					<Button variant="default">Publish</Button>
				</Dialog.Footer>
			</Dialog.Content>
		{/if}
	</Dialog.Root>
{/if}
