<script lang="ts">
	import { NDKDraft, NDKDVMRequest, NDKEvent } from '@nostr-dev-kit/ndk';
	import Post from './post.svelte';
	import Draft from './Draft.svelte';
	import Scheduled from './Scheduled.svelte';

	type Props = {
		events: NDKEvent[];
	};
	
	const { events }: Props = $props();
</script>

<div>
	{#each events as event (event.id)}
		{#if event instanceof NDKDraft}
			<Draft draft={event} />
		{:else if event instanceof NDKDVMRequest}
			<Scheduled schedule={event} />
		{:else}
			<Post {event} />
		{/if}
	{/each}
</div>
