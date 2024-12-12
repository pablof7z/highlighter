<script lang="ts">
	import { ndk } from '@/state/ndk';
	import { NDKDraft, NDKKind } from '@nostr-dev-kit/ndk';
	import RelativeTime from '@/components/RelativeTime.svelte';
	import type { EditorState } from '@/components/Studio/state.svelte';

	type Props = {
		editorState: EditorState;
		onSave?: (event: NDKDraft) => void;
	}

	const { editorState, onSave }: Props = $props();

	let status = $state<'Unsaved' | 'Saving' | 'Saved' | 'Error'>('Unsaved');

	let contentChanges = $state(0);
	let content = $state(editorState.content);

	let saveTimer: NodeJS.Timeout | null = null;

	$effect(() => {
		console.log(editorState.draft?.rawEvent())
		if (content !== editorState.content) {
			contentChanges++;
			content = editorState.content;
		}

		// save after 30 seconds of inactivity if there are changes
		if (contentChanges > 0) {
			if (saveTimer) {
				clearTimeout(saveTimer);
			}
			saveTimer = setTimeout(save, 5000);
		}

		// if there are over 500 changes, save immediately
		if (contentChanges > 500) {
			save();
		}
	})
	
	$effect(() => {
		if (editorState.draft) {
			status = 'Saved';
		}
	});

	let error = $state<string | null>(null);

	const NEW_DRAFT_AUTOSAVE_THRESHOLD = 100;

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
		if (!editorState.content) {
			console.error('No draft to save');
			return;
		}

		const draftExisted = !!editorState.draft;

		let isPrimaryDraft = false;
		let draftEvent: NDKDraft;

		if (manual) {
			draftEvent = editorState.draft || new NDKDraft(ndk);
			isPrimaryDraft = true;
		} else if (draftExisted || contentChanges > NEW_DRAFT_AUTOSAVE_THRESHOLD) { // only auto-save a draft if there are enough changes
			isPrimaryDraft = !draftExisted; // only set it as the main draft if this is the first time we're saving
			draftEvent = new NDKDraft(ndk);

			if (draftExisted) {
				draftEvent.kind = NDKKind.DraftCheckpoint;
				draftEvent.tag(editorState.draft);
			}
		} else {
			console.log('not saving draft');
			return;
		}

		const event = editorState.generateEvent();
		draftEvent.event = event;
		status = 'Saving';
		error = null;
		draftEvent
			.save({ publish: true })
			.then(() => {
				status = 'Saved';
				contentChanges = 0;

				if (isPrimaryDraft) {
					editorState.draft = draftEvent;
				}
				onSave?.(draftEvent);
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
			{#if editorState.draft}
				<span class="text-[10px] font-light leading-tight text-muted-foreground/70"><RelativeTime event={editorState.draft} /> ago</span>
			{/if}
		</div>
	{:else}
		<div class="flex flex-col items-start">
			{status}
			{#if editorState.draft}
				Last saved <span class="text-[10px] font-light leading-tight text-muted-foreground/70"><RelativeTime event={editorState.draft} /> ago</span>
			{/if}
		</div>
	{/if}
</button>