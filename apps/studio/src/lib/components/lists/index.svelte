<script lang="ts">
	import { NDKDraft } from '@nostr-dev-kit/ndk';
	import Post from './post.svelte';
	import Draft from './Draft.svelte';

	const { events } = $props();
</script>

<div>
	{#each events as event (event.id)}
		{#if event instanceof NDKDraft}
			<Draft draft={event} />
		{:else}
			<Post {event} />
		{/if}
	{/each}
</div>
