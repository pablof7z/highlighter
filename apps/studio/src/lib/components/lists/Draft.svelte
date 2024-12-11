<script lang="ts">
	import { wrapEvent } from '@highlighter/common';
	import type { NDKDraft, NDKEvent } from '@nostr-dev-kit/ndk';
	import Item from './Item.svelte';
	import { currentUser } from '@/state/current-user.svelte';

	let { draft } = $props();
	let event = $state<NDKEvent | null>(null);
	let editUrl = $state<string | null>(null);
	let error = $state<string | null>(null);

	const user = $derived.by(currentUser);

	draft
		.getEvent()
		.then((e) => {
			console.log(e);
			if (e) {
				event = wrapEvent(e);
				editUrl = `/editor/article/${draft.encode()}`;
			}
		})
		.catch((e) => {
			console.log('error with content', draft.content);
			console.error(e);
			error = e.message;
		});
	
	const author = $derived(draft.pubkey !== user.pubkey ? draft.author : null);
</script>

{#if event}
	<a href={editUrl} class="hover:bg-secondary/20 block w-full">
		<Item
			{author}
			byline={"from "}
			title={event.title}
			image={event.image}
			eventId={draft.id}
			{editUrl}
			onDelete={() => draft.delete()}
		/>
	</a>
{:else}
	<div>
		{error}
		{draft.tagValue('k')}
	</div>
{/if}
