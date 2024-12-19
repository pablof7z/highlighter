<script lang="ts">
	import * as DropdownMenu from '@components/ui/dropdown-menu/index.js';
	import { Button } from '@components/ui/button/index.js';
	import Avatar from '@components/user/Avatar.svelte';
	import Name from '@components/user/Name.svelte';
	import { currentUserProfile, logout } from '@/state/current-user.svelte';
	import { prettifyNip05 } from '@nostr-dev-kit/ndk-svelte-components';
	import { goto } from '$app/navigation';
	import { LogOut, Settings } from 'lucide-svelte';
	import { NDKRelayStatus, type NDKRelay } from '@nostr-dev-kit/ndk';
	import { ndk } from '@/state/ndk';

	const profile = currentUserProfile();

	let relays = $state<NDKRelay[]>(
		ndk.pool.connectedRelays()
	);

	// declare enum NDKRelayStatus {
	// 	DISCONNECTING = 0,// 0
	// 	DISCONNECTED = 1,// 1
	// 	RECONNECTING = 2,// 2
	// 	FLAPPING = 3,// 3
	// 	CONNECTING = 4,// 4
	// 	CONNECTED = 5,// 5
	// 	AUTH_REQUESTED = 6,// 6
	// 	AUTHENTICATING = 7,// 7
	// 	AUTHENTICATED = 8
	// }

	function relayStatusColor(status: NDKRelayStatus) {
		switch (status) {
			case NDKRelayStatus.AUTH_REQUESTED: return 'bg-orange-500';
			case NDKRelayStatus.AUTHENTICATED:
			case NDKRelayStatus.AUTHENTICATING:
			case NDKRelayStatus.CONNECTED: return 'bg-green-500';
			case NDKRelayStatus.CONNECTING: return 'bg-yellow-500';
			case NDKRelayStatus.DISCONNECTED: return 'bg-red-500';
			default:
				return 'bg-red-500';
		}
	}
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		<Button variant="ghost" class="relative h-10 w-10 rounded-full">
			<Avatar {profile} size="medium" />
		</Button>
	</DropdownMenu.Trigger>
	<DropdownMenu.Content class="w-56" align="end">
		<DropdownMenu.Label class="font-normal flex flex-row gap-4">
			<Avatar {profile} size="small" />
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
		<DropdownMenu.Separator />
		<DropdownMenu.Label class="font-normal flex flex-row gap-4 text-muted-foreground uppercase text-xs">
			Relays
		</DropdownMenu.Label>
		<DropdownMenu.Label>
			{#each relays as relay (relay.url)}
				<div class="text-xs text-muted-foreground flex flex-row items-center justify-between">
					{relay.url}
					<span class="text-xs text-muted-foreground w-2 h-2 rounded-full {relayStatusColor(relay.status)}"></span>
				</div>
			{/each}
		</DropdownMenu.Label>
	</DropdownMenu.Content>
</DropdownMenu.Root>
