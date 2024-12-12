<script lang="ts">
	import * as DropdownMenu from '@components/ui/dropdown-menu/index.js';
	import { Button } from '@components/ui/button/index.js';
	import Avatar from '@components/user/Avatar.svelte';
	import Name from '@components/user/Name.svelte';
	import { currentUserProfile, logout } from '@/state/current-user.svelte';
	import { prettifyNip05 } from '@nostr-dev-kit/ndk-svelte-components';
	import { goto } from '$app/navigation';
	import { LogOut, Settings } from 'lucide-svelte';

	const profile = currentUserProfile();
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		<Button variant="ghost" class="relative h-10 w-10 rounded-full">
			<Avatar {profile} size="medium" />
		</Button>
	</DropdownMenu.Trigger>
	<DropdownMenu.Content class="w-56" align="end">
		<DropdownMenu.Label class="font-normal">
			<div class="flex flex-col space-y-1">
				<Name {profile} class="text-sm font-medium leading-none" />
				<p class="text-muted-foreground text-xs leading-none">
					{profile?.nip05 ? prettifyNip05(profile?.nip05) : profile?.user?.npub}
				</p>
			</div>
		</DropdownMenu.Label>
		<DropdownMenu.Separator />
		<DropdownMenu.Group>
			<DropdownMenu.Item onclick={() => goto('/settings')}>
				<Settings size={16} />
				Settings
			</DropdownMenu.Item>
		</DropdownMenu.Group>
		<DropdownMenu.Separator />
		<DropdownMenu.Item onclick={logout}>
			<LogOut size={16} />
			Log out</DropdownMenu.Item
		>
	</DropdownMenu.Content>
</DropdownMenu.Root>
