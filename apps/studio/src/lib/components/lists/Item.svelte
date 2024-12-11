<script lang="ts">
	import { DotsHorizontal, Image, Trash } from 'svelte-radix';
	import Button from '@components/ui/button/button.svelte';
	import * as DropdownMenu from '@components/ui/dropdown-menu';
	import type { NDKUser } from '@nostr-dev-kit/ndk';
	import Avatar from '@components/user/Avatar.svelte';
	import Name from '@components/user/Name.svelte';
	import { Profile } from '../user/profile.svelte';

	type Props = {
		author?: NDKUser;
		title: string;
		image: string;
		timestamp: number;
		editUrl: string;
		eventId?: string;
		byline?: string;
		onDelete: () => void;
	};

	const { author, title, image, editUrl, byline, onDelete, eventId, timestamp }: Props = $props();

	let imageLoaded = $state(false);
	let profile = author ? new Profile(author) : null;
</script>

<div class="border-border mb-2 flex w-full flex-row items-center gap-4 border-b py-2">
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

	<div class="flex h-16 w-1/2 grow flex-col">
		<h1 class="grow truncate whitespace-nowrap text-sm font-medium">
			{title}
		</h1>

		{#if author && profile}
			<div class="text-muted-foreground flex flex-row items-center gap-1 text-xs">
				<Avatar {profile} />
				{byline ?? ''}
				<Name {profile} />
			</div>
		{/if}

		{#if timestamp}
			<div class="text-muted-foreground text-xs">
				{new Date(timestamp*1000).toLocaleDateString()}
			</div>
		{/if}
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
					{#if eventId}
						<DropdownMenu.Item onclick={() => navigator.clipboard.writeText(eventId)}>
							Copy Event ID
						</DropdownMenu.Item>
					{/if}
					<DropdownMenu.Item class="text-red-500" onclick={onDelete}>
						<Trash />
						Delete
					</DropdownMenu.Item>
				</DropdownMenu.Group>
			</DropdownMenu.Content>
		</DropdownMenu.Root>
	</div>
</div>
