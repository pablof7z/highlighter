<script lang="ts">
	import Input from '@components/ui/input/input.svelte';
	import { type Hexpubkey, NDKUser } from '@nostr-dev-kit/ndk';
	import { nip19 } from 'nostr-tools';
	import { ndk } from '@/state/ndk';
	import * as Dialog from '@/components/ui/dialog/';
	import { Search, Send, Users2, X } from 'lucide-svelte';
	import { Button } from '@/components/ui/button';
	import AvatarWithName from '@/components/user/AvatarWithName.svelte';
	import Name from '@/components/user/Name.svelte';
	import { ArrowRight, PaperPlane } from 'svelte-radix';
	import type { PostState } from '../state.svelte';

	type Props = {
		open: boolean;
		postState: PostState;
	}

	let { open = $bindable(), postState = $bindable() }: Props = $props();

	// $: {
	// 	actionButtons = [];
	// 	if ($state.proposalRecipient) {
	// 		actionButtons.push({ name: 'Close', fn: closeModal, buttonProps: { variant: 'link' } });
	// 	} else {
	// 		actionButtons.push({ name: 'Cancel', fn: closeModal, buttonProps: { variant: 'link' } });
	// 	}

	// 	if (!$state.proposalRecipient) {
	// 		if (pubkey) {
	// 			actionButtons.push({
	// 				name: 'Continue',
	// 				fn: () => {
	// 					$state.proposalRecipient = pubkey;
	// 					$state.proposalMode = true;
	// 					closeModal();
	// 				},
	// 				buttonProps: { variant: 'default' }
	// 			});
	// 		} else {
	// 			actionButtons.push({ name: 'Search', fn: setUser, buttonProps: { variant: 'default' } });
	// 		}
	// 	} else {
	// 		actionButtons.push({
	// 			name: 'Disable Proposal Mode',
	// 			fn: () => {
	// 				disableProposalMode();
	// 				closeModal();
	// 			}
	// 		});
	// 	}
	// }

	function disableProposalMode() {
		postState.proposalRecipient = undefined;
	}

	let recipient: string = $state('');

	async function setUser() {
		try {
			const data = nip19.decode(recipient);
			if (data.type === 'npub') {
				postState.proposalRecipient = data.data as Hexpubkey;
			} else if (data.type === 'nprofile') {
				postState.proposalRecipient = data.data.pubkey;
			}
		} catch (e) {
			const user = await NDKUser.fromNip05(recipient, ndk);
			if (user) {
				postState.proposalRecipient = user.pubkey;
			}
		}
	}

	function handleKeydown(e: KeyboardEvent) {
		console.log(e.key);
		if (e.key === 'Enter') {
			setUser();
		}
	}

	let enabled = $state(!!postState.proposalRecipient || !!recipient);
</script>

<Dialog.Root bind:open>
	<Dialog.Content class="max-w-sm">
		{#if enabled}
			<Dialog.Title>Proposal Mode</Dialog.Title>
		{/if}

		{#if !enabled}
			<div class="flex flex-col items-center p-4">
				<Users2 size="120" class="text-muted-foreground" strokeWidth={1} />
				<h1 class="text-2xl font-bold">Proposal Mode</h1>
				<p class="text-center text-muted-foreground">
					Prepare a post and propose it to someone else to publish it under their name.
				</p>
			</div>

			<Dialog.Footer>
				<Button class="w-full"variant="default" onclick={() => { enabled = true; }}>
					Continue
					<ArrowRight />
				</Button>
			</Dialog.Footer>
		{:else}
			{#if postState.proposalRecipient}
				<p class="text-foreground font-medium">Recipient</p>

				<div class="bg-secondary flex flex-row items-center justify-between gap-2 rounded-md p-4">
					<AvatarWithName of={postState.proposalRecipient} avatarSize="large" />

					<div class="flex flex-col gap-1">
						<button
							class="bg-foreground text-background rounded-full p-1 text-sm"
							onclick={disableProposalMode}
						>
							<X />
						</button>
					</div>
				</div>

				<p class="text-muted-foreground text-sm">
					Once you are ready to send the proposal, go ahead with publishing;
					<Name of={postState.proposalRecipient} />
					will receive a message inviting
					him to review and publish the post in their Highlighter Studio.
				</p>
			{:else}
				<p>Who should consider publishing this post?</p>
				<Input
					bind:value={recipient}
					placeholder="Enter the recipient's nostr address (e.g. pablo@f7z.io) or npub"
					onkeydown={handleKeydown}
				/>
			{/if}

			<Dialog.Footer>
				{#if postState.proposalRecipient}
					<div class="flex flex-row justify-between w-full">
						<Button variant="outline" class="text-red-500" onclick={disableProposalMode}>
							Disable Proposal Mode
						</Button>
						<Button variant="outline" onclick={() => { open = false; }}>Done</Button>
					</div>
				{:else}
					<Button variant="default" onclick={setUser} disabled={recipient.length === 0}>
						<Search />
						Search
					</Button>
				{/if}
			</Dialog.Footer>
		{/if}
	</Dialog.Content>
</Dialog.Root>
