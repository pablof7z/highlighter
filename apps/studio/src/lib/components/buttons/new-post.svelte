<script lang="ts">
	import * as DropdownMenu from '$lib/components/ui/dropdown-menu/index.js';
	import { CaretDown, FileText } from 'svelte-radix';
	import Button from '../ui/button/button.svelte';
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		<Button>
			New Post

			<CaretDown class="h-4 w-4" />
		</Button>
	</DropdownMenu.Trigger>
	<DropdownMenu.Content>
		<DropdownMenu.Group>
			<DropdownMenu.Item class="px-4 py-2">
				<a href="/editor/article/new" class="flex w-full items-center gap-2">
					<FileText class="h-4 w-4" />
					Text post
				</a>
			</DropdownMenu.Item>
		</DropdownMenu.Group>
	</DropdownMenu.Content>
</DropdownMenu.Root>
