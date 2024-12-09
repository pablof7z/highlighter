<script lang="ts">
	import { DotsHorizontal, Image, Trash } from 'svelte-radix';
	import Button from '@components/ui/button/button.svelte';
	import * as DropdownMenu from '@components/ui/dropdown-menu';

	const { title, image, editUrl, onDelete } = $props() as {
		title?: string | undefined;
		image?: string;
		editUrl?: string;
		onDelete?: () => void;
	};

	let imageLoaded = $state(false);
</script>

<div class="border-border mb-2 flex h-24 w-full flex-row gap-4 border-b pt-2">
	<div class="flex-none">
		{#if !imageLoaded}
			<div class="bg-secondary flex h-16 w-16 items-center justify-center rounded-xl">
				<Image size="24" class="text-muted-foreground" />
			</div>
		{/if}
		<img
			onload={() => (imageLoaded = true)}
			src={image}
			alt={title}
			class="h-16 w-16 rounded-xl object-cover"
			class:hidden={!imageLoaded}
		/>
	</div>

	<div class="flex w-1/2 grow flex-col">
		<h1 class="grow truncate whitespace-nowrap text-sm font-bold">
			{title}
		</h1>
	</div>

	<div>
		<DropdownMenu.Root>
			<DropdownMenu.Trigger>
				<Button variant="ghost" size="icon">
					<DotsHorizontal />
				</Button>
			</DropdownMenu.Trigger>
			<DropdownMenu.Content>
				<DropdownMenu.Group>
					<DropdownMenu.Item>
						<a href={editUrl}> Edit </a>
					</DropdownMenu.Item>
					<DropdownMenu.Item class="text-red-500" onclick={onDelete}>
						<Trash />
						Delete
					</DropdownMenu.Item>
				</DropdownMenu.Group>
			</DropdownMenu.Content>
		</DropdownMenu.Root>
	</div>
</div>
