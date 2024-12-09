<script lang="ts">
	import '@fontsource/spectral';
	import '@fontsource/spectral/300.css';
	import '@fontsource/spectral/300-italic.css';
	import '@fontsource/spectral/500.css';
	import '@fontsource/spectral/500-italic.css';
	import '@fontsource/spectral/600.css';
	import '@fontsource/spectral/600-italic.css';

	import { ndk } from '@/state/ndk';
	import { NDKNip07Signer } from '@nostr-dev-kit/ndk';
	import { onMount } from 'svelte';
	import { currentUser } from '@/state/current-user.svelte';
	let { children } = $props();

	onMount(() => {
		if (window.nostr && !ndk.signer) {
			ndk.signer = new NDKNip07Signer();
		}
	});
</script>

{#if currentUser() !== null}
	{@render children()}
{:else}
	<div class="flex h-screen flex-col items-center justify-center">
		<h1 class="text-2xl font-bold">Please sign in</h1>
	</div>
{/if}
