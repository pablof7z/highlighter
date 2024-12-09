<script lang="ts">
	import { Button } from './button';
	import { Input } from './input';

	let { relays = $bindable<string[]>() } = $props();

	let newRelay = $state('');

	function addNewRelay() {
		relays.push(newRelay);
		newRelay = '';
	}
</script>

<div class="flex flex-col gap-2">
	{#each relays as relay, index}
		<div class="flex flex-row items-center justify-between gap-2">
			<Input type="text" bind:value={relays[index]} />
			<Button variant="secondary" onclick={() => relays.splice(index, 1)}>Remove</Button>
		</div>
	{/each}

	<Input
		type="text"
		bind:value={newRelay}
		onfocus={() => {
			if (newRelay.length === 0) newRelay = 'wss://';
		}}
	/>
	<Button variant="secondary" onclick={addNewRelay}>Add</Button>
</div>
