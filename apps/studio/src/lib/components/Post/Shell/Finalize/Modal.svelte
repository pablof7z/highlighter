<script lang="ts">
	import * as Dialog from '@/components/ui/dialog';
	import { Button } from '@/components/ui/button';
	import SettingsModal from '../Settings/Modal.svelte';
	import { ArrowRightIcon, Loader2, MessageCircleWarning, Plane } from 'lucide-svelte';
	import Name from '@/components/user/Name.svelte';
	import CoverImage from '../buttons/CoverImage.svelte'
	import Checks from './Checks.svelte';
	import { fade } from 'svelte/transition';
	import type { ButtonStatus } from '@/components/ui/button/button.svelte';
	import type { NDKEvent } from '@nostr-dev-kit/ndk';
	import type { PostState } from '../../state/index.svelte';

	interface Props {
		postState: PostState;
		open: boolean;
		onSuccess: (event: NDKEvent) => void;
	}

	let {
		postState = $bindable(),
		open = $bindable(),
		onSuccess
	}: Props = $props();

	let showSettings = $state(false);
	let error = $state(null);

	let status = $state<ButtonStatus>('initial');

	function _publish() {
		status = 'loading';
		error = null;
		postState.publish()
			.then((event) => {
				status = 'success';
				setTimeout(() => {
					open = false;
					onSuccess?.(event)
				}, 1500);
			})
			.catch((e) => {
				error = e;
				status = 'error';
			})
	}

	let allGood = $state(false);

	const publishButtonEnabled = $derived(allGood);
</script>

<Dialog.Root bind:open>
	{#if postState.proposalRecipient}
		<Dialog.Content>
			<Dialog.Title>Ready to send proposal?</Dialog.Title>
			<Dialog.Description>
				This post will be sent in private, for the recipient to consider publishing under their
				name.
			</Dialog.Description>

			<Dialog.Footer>
				<Button variant="link" onclick={() => (showSettings = true)}>Advanced</Button>
				<Button variant="default" onclick={_publish} {status}>
					Send proposal to
					<Name of={postState.proposalRecipient} />
					<ArrowRightIcon class="h-4 w-4" />
				</Button>
			</Dialog.Footer>
		</Dialog.Content>
	{:else if postState.publishAt}
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

			{#if postState.type === 'article'}
				<div class="flex flex-row items-start gap-4">
					<CoverImage
						{postState}
						class="w-32 h-32 flex-none"
						imgProps={{ class: "p-0 h-32 w-32 rounded-lg object-cover" }}
					/>

					<div class="flex flex-col gap-1">
						<h2 class="text-base font-medium">{postState.title}</h2>
						<h3 class="text-muted-foreground/70 text-sm">{postState.summary}</h3>
					</div>
				</div>
			{/if}

			<Checks {postState} bind:allGood />

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
					disabled={!publishButtonEnabled || status === 'loading'}
					{status}
				>
					Publish
				</Button>
			</Dialog.Footer>
		</Dialog.Content>
	{/if}

	<SettingsModal bind:postState bind:open={showSettings} />
</Dialog.Root>
