<script lang="ts">
	import * as Dialog from '@/components/ui/dialog';
	import type { EditorState } from '../../state.svelte';
	import { Button } from '@/components/ui/button';
	import SettingsModal from '../../Settings/Modal.svelte';
	import { publish } from '../../state.svelte';
	import { ArrowRightIcon, Loader2, MessageCircleWarning, Plane } from 'lucide-svelte';
	import Name from '@/components/user/Name.svelte';
	import CoverImage from '../buttons/CoverImage.svelte';
	import Checks from './Checks.svelte';
	import { fade, slide } from 'svelte/transition';

	interface Props {
		editorState: EditorState;
		open: boolean;
		onSuccess: () => void;
	}

	let {
		editorState = $bindable(),
		open = $bindable(),
		onSuccess
	}: Props = $props();

	let showSettings = $state(false);
	let error = $state(null);

	function _publish() {
		acting = true;
		error = null;
		publish(editorState)
			.then(() => {
				open = false;
				onSuccess?.();
			})
			.catch((e) => {
				error = e;
			})
			.finally(() => {
				acting = false;
			});
	}

	let allGood = $state(false);

	// Whether we are performing the action
	let acting = $state(false);

	const publishButtonEnabled = $derived(allGood && !acting);
</script>

<Dialog.Root bind:open>
	{#if editorState.proposalRecipient}
		<Dialog.Content>
			<Dialog.Title>Ready to send proposal?</Dialog.Title>
			<Dialog.Description>
				This post will be sent in private, for the recipient to consider publishing under their
				name.
			</Dialog.Description>

			<Dialog.Footer>
				<Button variant="link" onclick={() => (showSettings = true)}>Advanced</Button>
				<Button variant="default" onclick={_publish}>
					Send proposal to
					<Name of={editorState.proposalRecipient} />
					<ArrowRightIcon class="h-4 w-4" />
				</Button>
			</Dialog.Footer>
		</Dialog.Content>
	{:else if editorState.publishAt}
		<Dialog.Content>
			<Dialog.Title>Ready to schedule?</Dialog.Title>

			<Dialog.Footer>
				<Button variant="link" onclick={() => (showSettings = true)}>Advanced</Button>
				<Button variant="default" onclick={_publish}>Schedule</Button>
			</Dialog.Footer>
		</Dialog.Content>
	{:else}
		<Dialog.Content>
			<Dialog.Title>Ready to publish?</Dialog.Title>
			<Dialog.Description class="sr-only">Publish your content here.</Dialog.Description>

			<div class="flex flex-row items-start gap-4">
				<CoverImage
					{editorState}
					class="w-32 h-32 flex-none"
					imgProps={{ class: "p-0 h-32 w-32 rounded-lg object-cover" }}
				/>

				<div class="flex flex-col gap-1">
					<h2 class="text-base font-medium">{editorState.title}</h2>
					<h3 class="text-muted-foreground/70 text-sm">{editorState.summary}</h3>
				</div>
			</div>

			<Checks {editorState} bind:allGood />

			<Dialog.Footer>
				{#if error}
					<div class="text-sm text-red-500 flex flex-row gap-6 items-center rounded-lg grow" transition:fade>
						<div class="flex flex-row  items-center gap-2 grow">
							<MessageCircleWarning class="h-4 w-4" />
							{error}
						</div>
					</div>
				{/if}
				
				<Button variant="ghost" onclick={() => (showSettings = true)}>Advanced</Button>
				<Button
					variant="default"
					onclick={_publish}
					disabled={!publishButtonEnabled}
					loading={acting}
				>
					Publish
				</Button>
			</Dialog.Footer>
		</Dialog.Content>
	{/if}

	<SettingsModal bind:editorState bind:open={showSettings} />
</Dialog.Root>
