<script lang="ts">
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import { CaretDown, FileText } from 'svelte-radix';
	import Button from '../ui/button/button.svelte';
	import { Import, MessageCircle } from 'lucide-svelte';

	const { onImport } = $props();
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
			<DropdownMenu.Item>
				<a href="/editor/article/new" class="flex w-full items-center gap-2">
					<FileText class="h-4 w-4" />
					Long Form
				</a>
			</DropdownMenu.Item>

			<DropdownMenu.Item>
				<a href="/editor/thread/new" class="flex w-full items-center gap-2">
					<MessageCircle class="h-4 w-4" />
					Thread
				</a>
			</DropdownMenu.Item>

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
