<script lang="ts">
	import { DotsHorizontal, ExternalLink, Image } from 'svelte-radix';
	import Button from '@components/ui/button/button.svelte';
	import * as DropdownMenu from '@components/ui/dropdown-menu';
	import type { NDKEvent, NDKUser } from '@nostr-dev-kit/ndk';
	import Avatar from '@components/user/Avatar.svelte';
	import Name from '@components/user/Name.svelte';
	import { Profile } from '../user/profile.svelte';
	import { Copy, FileJson2, Pencil, Share, Trash } from 'lucide-svelte';
	import { goto } from '$app/navigation';
	import { currentUser } from '@/state/current-user.svelte';
	import Badge from '../ui/badge/badge.svelte';

	const user = $derived.by(currentUser);

	type Props = {
		author?: NDKUser | null;
		title: string;
		image: string;
		timestamp: number;
		event?: NDKEvent;
		editUrl: string;
		byline?: string;
		tags?: string[];
		onShare?: () => void;
		onDelete: () => void;
		stats: Record<string, number>;
		viewLink?: string;
	};

	const {
		author,
		title,
		image,
		editUrl,
		byline,
		tags,
		event,
		onDelete,
		timestamp,
		onShare,
		stats,
		viewLink
	}: Props = $props();

	let imageLoaded = $state(false);
	let profile = author ? new Profile(author) : null;
</script>

<div class="border-border mb-2 flex w-full flex-row items-center gap-4 border-b py-2">
	<div class="flex h-16 w-1/2 flex-row gap-4 overflow-clip">
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

		<div class="flex flex-col truncate">
			<h1 class="grow truncate whitespace-nowrap text-sm font-medium">
				{title}
			</h1>

			<div class="flex flex-row gap-4">
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

				{#if tags}
					<div class="text-muted-foreground text-xs">
						{#each tags as tag}
							<Badge variant="outline" class="text-xs">
								{tag}
							</Badge>
						{/each}
					</div>
				{/if}
			</div>
		</div>
	</div>

	<div class="flex w-1/2 flex-row gap-8 justify-end">
		{#if stats}
			{#each Object.entries(stats) as [label, count]}
				{@render stat(count, label)}
			{/each}
		{/if}

		<div class="flex flex-row gap-2 items-center">
			{#if viewLink}
				<Button variant="secondary" size="icon" onclick={() => window.open(viewLink, '_blank')}>
					<ExternalLink class="w-4 h-4" />
				</Button>
			{/if}

			<DropdownMenu.Root>
				<DropdownMenu.Trigger>
					<Button variant="ghost" size="icon">
						<DotsHorizontal />
					</Button>
				</DropdownMenu.Trigger>
				<DropdownMenu.Content>
					<DropdownMenu.Group>
						<DropdownMenu.Item onclick={() => goto(editUrl)}>
							<Pencil class="w-4 h-4 mr-2" />
							Edit
						</DropdownMenu.Item>

						{#if event}
							<DropdownMenu.Item onclick={() => navigator.clipboard.writeText(event.encode())}>
								<Copy class="w-4 h-4 mr-2" />
								Copy Event ID
							</DropdownMenu.Item>

							<DropdownMenu.Item onclick={() => navigator.clipboard.writeText(JSON.stringify(event.rawEvent(), null, 4))}>
								<FileJson2 class="w-4 h-4 mr-2" />
								Copy Raw Event
							</DropdownMenu.Item>
						{/if}

						{#if onShare}
							<DropdownMenu.Item onclick={onShare}>
								<Share class="w-4 h-4 mr-2" />
								Share
							</DropdownMenu.Item>
						{/if}

						{#if event?.pubkey === user?.pubkey}
							<DropdownMenu.Separator />
							
							<DropdownMenu.Item class="text-red-500" onclick={onDelete}>
								<Trash class="w-4 h-4 mr-2" />
								Delete
							</DropdownMenu.Item>
						{/if}

						{#if event}
							<DropdownMenu.Item onclick={() => event.delete()}>
								{#each event.onRelays as relay}
									{relay.url}
								{/each}
							</DropdownMenu.Item>
						{/if}
					</DropdownMenu.Group>
				</DropdownMenu.Content>
			</DropdownMenu.Root>
		</div>
	</div>
</div>


{#snippet stat(count: number, label: string)}
	<div class="flex flex-col gap-2 items-center">
		<span class="font-mono text-sm text-foreground">
			{count}
		</span>
		<span class="text-xs text-muted-foreground">
			{label}
		</span>
	</div>
{/snippet}