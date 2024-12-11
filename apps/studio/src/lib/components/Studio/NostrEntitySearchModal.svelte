<script lang="ts">
	import * as Dialog from '@components/ui/dialog';
	import { Button } from '../ui/button';
	import NostrEntitySearch from '../NostrEntitySearch.svelte';

	let { open = $bindable(), title = 'Search for users or events', onSelect, onClose } = $props();

	// $: if (selectedIndex >= 0 && itemRefs[selectedIndex]) {
	// 	itemRefs[selectedIndex].scrollIntoView({ block: 'nearest', behavior: 'smooth' });
	// }

	let selectedEncoding: string | undefined = $state(undefined);

	function _onSelect(encoding: string) {
		onSelect(encoding);
		close();
	}

	function close() {
		open = false;
		onClose?.();
	}

	
</script>

<Dialog.Root bind:open>
	<Dialog.Content class="h-[50vh] flex flex-col">
		<Dialog.Title>Search</Dialog.Title>

		<NostrEntitySearch
			bind:selectedEncoding
			onSelect={_onSelect}
		/>

		<Dialog.Footer>
			{#if selectedEncoding}
				<Button variant="default">Insert</Button>
			{:else}
				<Button variant="secondary" onclick={close}>Close</Button>
			{/if}
		</Dialog.Footer>
	</Dialog.Content>
</Dialog.Root>
