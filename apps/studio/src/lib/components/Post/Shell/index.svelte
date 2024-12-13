<script lang="ts">
	import Article from './Article.svelte';
	import Thread from './Thread.svelte';
	import Header from './Header.svelte';
	import Footer from './Footer.svelte';
	import FinalizeModal from './Finalize/Modal.svelte';
	import SettingsModal from './Settings/Modal.svelte';
	import HistoryModal from './History/Modal.svelte';
	import { appState } from '@/state/app.svelte';
	import type { NDKDraft, NDKEvent } from '@nostr-dev-kit/ndk';
	import { goto, replaceState } from '$app/navigation';
	import { ArticleState } from '../state/article.svelte';
	import { ThreadState } from '../state/thread.svelte';
	import { type PostState } from '../state/index.svelte';
	import { toast } from 'svelte-sonner';
	import Post from '@/components/lists/post.svelte';
	type Props = {
		postState: PostState;
	}
	
	let { postState = $bindable() }: Props = $props();

	let settingsOpen = $state(false);
	let finalizeOpen = $state(false);
	let historyOpen = $state(false);

	function onPublish(events: NDKEvent[]) {
		if (postState.proposalRecipient) {
			toast.success('Proposal sent!', {
				description: 'You can share the link',
				duration: 20000,
				action: {
					label: 'Copy Link',
					onClick: () => {
						navigator.clipboard.writeText('https://studio.highlighter.com/article/' + events[0].encode());
					}
				}
			});
			goto('/');
		} else {
			appState.activeEvent = events[0];
			goto('/share');
		}
	}

	let hasDraft = $state(false);

	function onSaveDraft(draft: NDKDraft) {
		if (!hasDraft) {
			hasDraft = true;
			replaceState('/article/' + draft.encode(), {});
		}
	}
</script>

<div class="flex-col">
	<div class="w-full px-4 py-2 sticky top-0 bg-background z-40">
		<Header
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
	<Footer
		{postState}
		onOpenHistory={() => { historyOpen = true; }}
		onOpenSettings={() => { settingsOpen = true; }} />
</div>

<SettingsModal bind:postState bind:open={settingsOpen} />
<FinalizeModal bind:postState bind:open={finalizeOpen}
	onSuccess={onPublish}
/>

<HistoryModal bind:postState bind:open={historyOpen} />
