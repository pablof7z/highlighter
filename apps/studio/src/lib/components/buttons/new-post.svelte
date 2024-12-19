<script lang="ts">
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import { CaretDown, FileText } from 'svelte-radix';
	import Button, { type ButtonProps } from '../ui/button/button.svelte';
	import ImportModal from '@/components/Import/Modal.svelte';
	import { Import, MessageCircle, Plus } from 'lucide-svelte';
	import { appState } from '@/state/app.svelte';
	import { ArticleState } from '../Post/state/article.svelte';
	import { goto } from '$app/navigation';

	type Props = {
		onImport?: () => void;
		variant?: ButtonProps['variant'];
		children?: any;
		class?: string;
	}

	let { onImport, variant, children, class: className }: Props = $props();

	function newLongForm() {
		appState.postState = null;
		goto(`/article/new`);
	}

	function resume() {
		if (appState.postState instanceof ArticleState) {
			if (appState.postState.draft) {
				goto(`/article/${appState.postState.draft.encode()}`);
			} else {
				goto(`/article/new`);
			}
		}
	}

	const longFormToResume = $derived(appState.postState instanceof ArticleState && appState.postState.title.length > 0);

	let importModal = $state(false);
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		<Button {variant} size="sm" class={className}>
			{#if children}
				{@render children()}
			{:else}
				<Plus class="h-4 w-4" />
				New Post
			{/if}
		</Button>
	</DropdownMenu.Trigger>
	<DropdownMenu.Content class="w-48">
		<DropdownMenu.Group>
			<DropdownMenu.Item onclick={newLongForm}>
				<a href="/article/new" class="flex w-full items-center gap-2">
					<FileText class="h-4 w-4" />
					{#if longFormToResume}
						New
					{/if}
					Long Form
				</a>
			</DropdownMenu.Item>

			{#if longFormToResume}
				<DropdownMenu.Item onclick={resume} class="flex w-full items-center gap-2">
					<FileText class="h-4 w-4" />
					<div class="flex flex-col truncate">
						Resume
						<span class="text-xs text-muted-foreground whitespace-nowrap truncate
						">
							{appState.postState.title}
						</span>
					</div>
				</DropdownMenu.Item>
			{/if}

			<!--
				<DropdownMenu.Item>
					<a href="/editor/thread/new" class="flex w-full items-center gap-2">
					<MessageCircle class="h-4 w-4" />
					Thread
				</a>
			</DropdownMenu.Item> -->

			<DropdownMenu.Separator />

			<DropdownMenu.Item class="flex w-full items-center gap-2" onclick={() => onImport ? onImport() : importModal = true}>
				<Import class="h-4 w-4" />
				Import content
			</DropdownMenu.Item>
		</DropdownMenu.Group>
	</DropdownMenu.Content>
</DropdownMenu.Root>

{#if !onImport}
	<ImportModal bind:open={importModal} />
{/if}