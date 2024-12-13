<script lang="ts">
	import Article from './Article/index.svelte';
	import Thread from './Thread/index.svelte';
	import Toolbar from './Toolbar.svelte';
	import BottomToolbar from './BottomToolbar.svelte';
	import FinalizeModal from './Finalize/Modal.svelte';
	import SettingsModal from '../Settings/Modal.svelte';
	import HistoryModal from './History/Modal.svelte';
	import { appState } from '@/state/app.svelte';
	import type { NDKDraft, NDKEvent } from '@nostr-dev-kit/ndk';
	import { goto, replaceState } from '$app/navigation';
	import { ArticleState, ThreadState, type PostState } from '../state.svelte';
	import { toast } from 'svelte-sonner';

	type Props = {
		postState: PostState;
	}
	
	let { postState = $bindable() }: Props = $props();

	let settingsOpen = $state(false);
	let finalizeOpen = $state(false);
	let historyOpen = $state(false);

	function onPublish(event: NDKEvent) {
		if (postState.proposalRecipient) {
			toast.success('Proposal sent!', {
				description: 'You can share the link',
				duration: 20000,
				action: {
					label: 'Copy Link',
					onClick: () => {
						navigator.clipboard.writeText('https://studio.highlighter.com/editor/article/' + event.encode());
					}
				}
			});
			goto('/');
		} else {
			appState.activeEvent = event;
			goto('/share');
		}
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
			bind:postState
			onContinue={() => (finalizeOpen = true)}
			onSaveDraft={onSaveDraft}
		/>
	</div>

	{#if postState instanceof ArticleState}
		<Article bind:postState />
	{:else if postState instanceof ThreadState}
		<Thread bind:postState />
	{:else}
		Unhandled event type
	{/if}
</div>

<div class="fixed bottom-0 left-0 right-0 flex flex-row justify-between px-4 py-2">
	<BottomToolbar
		{postState}
		onOpenHistory={() => { historyOpen = true; }}
		onOpenSettings={() => { settingsOpen = true; }} />
</div>

<SettingsModal bind:postState bind:open={settingsOpen} />
<FinalizeModal bind:postState bind:open={finalizeOpen}
	onSuccess={onPublish}
/>

<HistoryModal bind:postState bind:open={historyOpen} />
