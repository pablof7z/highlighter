<script lang="ts">
	import { wrapEvent } from '@highlighter/common';
	import type { NDKDraft, NDKEvent } from '@nostr-dev-kit/ndk';
	import Item from './Item.svelte';

	let { draft } = $props() as { draft: NDKDraft };
	let event = $state<NDKEvent | null>(null);
	let editUrl = $state<string | null>(null);

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
		});
</script>

{#if event}
	<a href={editUrl} class="hover:bg-secondary/20 block w-full">
		<Item title={event.title} image={event.image} {editUrl} onDelete={() => draft.delete()} />
	</a>
{:else}
	<div>
		{draft.tagValue('k')}
	</div>
{/if}
