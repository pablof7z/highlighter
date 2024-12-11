<script lang="ts">
	import { Button } from './button';
	import { Input } from './input';
	import InputList from './InputList.svelte';

	let { relays = $bindable<string[]>() } = $props();

	let newRelay = $state('');

	function addNewRelay() {
		relays.push(newRelay);
		newRelay = '';
	}
</script>

<InputList
	bind:value={relays}
	placeholder="wss://relay.primal.net"
	prefix="wss://"
/>
