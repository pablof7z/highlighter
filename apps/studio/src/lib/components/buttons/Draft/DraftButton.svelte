<script lang="ts">
	import RelativeTime from '@/components/RelativeTime.svelte';
	import type { PostState } from '@/components/Studio/state.svelte';
	import { toast } from 'svelte-sonner';

	type Props = {
		postState: PostState;
	}

	const { postState }: Props = $props();

	let status = $state<'Unsaved' | 'Saving' | 'Saved' | 'Error'>(postState.draft ? 'Saved' : 'Unsaved');

	let stateChanges = $state(0);
	let stateSignatureCache = $state(postState.stateSignature);

	let saveTimer: NodeJS.Timeout | null = null;

	$effect(() => {
		if (stateSignatureCache !== postState.stateSignature) {
			stateChanges++;
			stateSignatureCache = postState.stateSignature;
		}

		// save after 30 seconds of inactivity if there are changes
		if (stateChanges > 0) {
			if (saveTimer) {
				clearTimeout(saveTimer);
			}
			saveTimer = setTimeout(save, 5000);
		}

		// if there are over 500 changes, save immediately
		if (stateChanges > 500) {
			save();
		}
	})

	const NEW_DRAFT_AUTOSAVE_THRESHOLD = 100;

	let error = $state<string | null>(null);

	/**
	 * Saves the current editor content as a draft event
	 * 
	 * @param manual - If true, saves as primary draft. If false, saves as checkpoint
	 * @returns void
	 * 
	 * The function:
	 * - Creates new draft event or uses existing one based on manual parameter
	 * - Sets draft type as checkpoint if auto-saving and draft already exists
	 * - Updates status indicators during save process
	 * - Updates editor state with new draft on successful manual saves
	 * - Handles errors and updates status accordingly
	 */
	function save(manual: boolean = false) {
		const draftExisted = !!postState.draft;
		
		if (!postState.shouldSaveDraft) {
			toast.error('No draft to save');
			return;
		}

		if (!(
			manual || // we always save when triggered manually
			draftExisted || // we are saving a checkpoint of an existing draft
			(stateChanges > NEW_DRAFT_AUTOSAVE_THRESHOLD) // we are auto-saving a draft that has enough changes to warrant a new draft
		)) return;

		status = 'Saving';
		error = null;
		postState.saveDraft(manual)
			.then(() => {
				status = 'Saved';
				stateChanges = 0;
			})
			.catch((e: any) => {
				console.error(e);
				status = 'Error';
				error = e.message;
			});
	}
</script>

<button onclick={() => save(true)} class="text-muted-foreground flex items-center gap-2 text-sm font-light">
	{#if status === 'Saved'}
		<div class="h-2 w-2 rounded-full bg-green-500"></div>
	{:else if status === 'Saving'}
		<div class="h-2 w-2 rounded-full bg-yellow-500"></div>
	{:else if status === 'Error'}
		<div class="h-2 w-2 rounded-full bg-red-500"></div>
	{:else}
		<div class="h-2 w-2 rounded-full bg-gray-500"></div>
	{/if}

	{#if status === 'Saved'}
		<div class="flex flex-col items-start">
			{status}
			{#if postState.draft}
				<span class="text-[10px] font-light leading-tight text-muted-foreground/70"><RelativeTime event={postState.draft} /> ago</span>
			{/if}
		</div>
	{:else}
		<div class="flex flex-col items-start">
			{status}
			{#if postState.draft}
				Last saved <span class="text-[10px] font-light leading-tight text-muted-foreground/70"><RelativeTime event={postState.draft} /> ago</span>
			{/if}
		</div>
	{/if}
</button>