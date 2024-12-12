<script lang="ts">
	import DraftButton from '@/components/buttons/Draft/DraftButton.svelte';
	import Button from '@/components/ui/button/button.svelte';
	import { ArrowLeft, DotsVertical } from 'svelte-radix';
	import * as DropdownMenu from '@/components/ui/dropdown-menu/';
	import Users from 'lucide-svelte/icons/users';
	import ProposalMode from './ProposalMode.svelte';
	import ImportModal from '@/components/Import/Modal.svelte';
	import { Import, Send, User2 } from 'lucide-svelte';
	import { Profile } from '@/components/user/profile.svelte';
	import Avatar from '@components/user/Avatar.svelte';
	import CollaboratorsModal from './CollaboratorsModal.svelte';
	import type { EditorState } from '../state.svelte';
	import type { NDKDraft } from '@nostr-dev-kit/ndk';

	type Props = {
		onContinue: () => void;
		editorState: EditorState;
		onSaveDraft?: (event: NDKDraft) => void;
	}

	let { onContinue, editorState, onSaveDraft }: Props = $props();

	let proposalModal = $state<boolean>(false);
	let importModal = $state<boolean>(false);

	let collaboratorsModal = $state<boolean>(false);

	$inspect(editorState);
	$inspect(editorState.title);

	let proposalRecipient = $derived(editorState.proposalRecipient ? new Profile(editorState.proposalRecipient) : null);
</script>

<div class="flex w-full items-center justify-between">
	<div class="flex flex-row items-center gap-2">
		<Button variant="secondary" size="icon" href="/">
			<ArrowLeft size="18" weight="bold" />
		</Button>

		<DraftButton {editorState} onSave={onSaveDraft} />
	</div>

	<div class="flex flex-row items-center gap-2">
		<DropdownMenu.Root>
			<DropdownMenu.Trigger>
				<Button size="icon" variant="secondary">
					<DotsVertical size={24} />
				</Button>
			</DropdownMenu.Trigger>
			<DropdownMenu.Content>
				<DropdownMenu.Group>
					<!-- <DropdownMenu.Item onclick={() => (collaboratorsModal = true)}>
						<Send class="mr-2" size={20} />
						Collaborators
					</DropdownMenu.Item> -->

					<!-- <DropdownMenu.Separator /> -->

					<DropdownMenu.Item onclick={() => (proposalModal = true)}>
						{#if !editorState.proposalRecipient}
							<Users class="mr-2" size={20} /> Proposal mode
						{:else}
							<Avatar profile={proposalRecipient} size="small" class="mr-2" />
							Edit proposal settings
						{/if}
					</DropdownMenu.Item>

					<DropdownMenu.Item onclick={() => (importModal = true)}>
						<Import class="mr-2" size={20} />
						Import content
					</DropdownMenu.Item>
				</DropdownMenu.Group>
			</DropdownMenu.Content>
		</DropdownMenu.Root>

		<Button variant="default" onclick={onContinue}>Continue</Button>
	</div>
</div>

<ProposalMode bind:open={proposalModal} editorState />
<!-- <CollaboratorsModal bind:open={collaboratorsModal} bind:editorState /> -->

<ImportModal bind:open={importModal} editorState />

