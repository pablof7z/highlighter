<script lang="ts">
	import { Home, Timer, Link1 } from 'svelte-radix';
	import RelayList from '../ui/RelayList.svelte';
	import type { EditorState } from './state.svelte';
	import * as Sidebar from '@components/ui/sidebar';
	import Relay from './Settings/Relay.svelte';

	let { editorState = $bindable() } = $props();

	const data = {
		nav: [
			{ name: 'Relays', icon: Home },
			{ name: 'Schedule', icon: Timer },
			{ name: 'Announce', icon: Link1 }
		]
	};
	let selectedSetting = $state('Relays');
</script>

<Sidebar.Provider class="items-start">
	<Sidebar.Root collapsible="none" class="hidden md:flex">
		<Sidebar.Content>
			<Sidebar.Group>
				<Sidebar.GroupContent>
					<Sidebar.Menu>
						{#each data.nav as item (item.name)}
							<Sidebar.MenuItem>
								<Sidebar.MenuButton isActive={item.name === 'Messages & media'}>
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
				<Relay bind:editorState />
			{/if}
		</div>
	</main>
</Sidebar.Provider>
