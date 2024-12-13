<script lang="ts">
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import { CaretDown, FileText } from 'svelte-radix';
	import Button from '../ui/button/button.svelte';
	import { Import, MessageCircle } from 'lucide-svelte';
	import { PostState } from '../Post/state/index.svelte';
	import { appState } from '@/state/app.svelte';
	import { ArticleState } from '../Post/state/article.svelte';
	import { goto } from '$app/navigation';

	const { onImport } = $props();

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
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		<Button size="sm">
			New Post

			<CaretDown class="h-4 w-4" />
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

			{#if onImport}
				<DropdownMenu.Separator />

				<DropdownMenu.Item class="flex w-full items-center gap-2" onclick={onImport}>
					<Import class="h-4 w-4" />
					Import content
				</DropdownMenu.Item>
			{/if}
		</DropdownMenu.Group>
	</DropdownMenu.Content>
</DropdownMenu.Root>
