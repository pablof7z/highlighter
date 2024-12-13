<script lang="ts">
	import { Home, Timer, Link1 } from 'svelte-radix';
	import * as Sidebar from '@components/ui/sidebar';
	import Relay from './Relay.svelte';
	import DollarSign from 'lucide-svelte/icons/dollar-sign';
	import { Image } from 'lucide-svelte';
	import Metadata from './Metadata.svelte';
	import Schedule from './Schedule.svelte';
	import { onMount } from 'svelte';

	let { postState = $bindable(), selectedSetting = $bindable() } = $props();

	onMount(() => {
		if (!selectedSetting || selectedSetting === '') {
			selectedSetting = 'Metadata';
		}
	})

	const data = {
		nav: [
			{ name: 'Metadata', icon: Image },
			{ name: 'Relays', icon: Home },
			{ name: 'Schedule', icon: Timer },
			// { name: 'Announce', icon: Link1 },
			// { name: 'Monetization', icon: DollarSign }
		]
	};
</script>

<Sidebar.Provider
	class="items-start"
	style="--sidebar-width: 10rem; --sidebar-width-mobile: 10rem;"
>
	<Sidebar.Root collapsible="icon" class="hidden md:flex">
		<Sidebar.Content>
			<Sidebar.Group>
				<Sidebar.GroupContent>
					<Sidebar.Menu>
						{#each data.nav as item (item.name)}
							<Sidebar.MenuItem>
								<Sidebar.MenuButton isActive={item.name === selectedSetting}>
									{#snippet child({ props })}
										<button onclick={() => (selectedSetting = item.name)} {...props}>
											<item.icon />
											<span>{item.name}</span>
										</button>
									{/snippet}
								</Sidebar.MenuButton>
							</Sidebar.MenuItem>
						{/each}
					</Sidebar.Menu>
				</Sidebar.GroupContent>
			</Sidebar.Group>
		</Sidebar.Content>
	</Sidebar.Root>
	<main class="flex h-[480px] flex-1 flex-col overflow-hidden">
		<div class="flex flex-1 flex-col gap-4 overflow-y-auto p-4">
			<h1 class="text-2xl font-bold">{selectedSetting}</h1>

			{#if selectedSetting === 'Relays'}
				<Relay bind:postState />
			{:else if selectedSetting === 'Metadata'}
				<Metadata bind:postState />
			{:else if selectedSetting === 'Schedule'}
				<Schedule bind:postState />
			{/if}
		</div>
	</main>
</Sidebar.Provider>

