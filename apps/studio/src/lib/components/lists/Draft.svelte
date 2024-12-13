<script lang="ts">
	import { wrapEvent } from '@highlighter/common';
	import type { NDKDraft, NDKEvent } from '@nostr-dev-kit/ndk';
	import Item from './Item.svelte';
	import { currentUser } from '@/state/current-user.svelte';
	import { ArticleState } from '../Post/state/article.svelte';
	import { appState } from '@/state/app.svelte';
	import { goto } from '$app/navigation';

	type Props = {
		draft: NDKDraft;
	};

	let { draft }: Props = $props();
	let event = $state<NDKEvent | null>(null);
	let editUrl = $state<string | null>(null);
	let error = $state<string | null>(null);

	const user = $derived.by(currentUser);

	draft
		.getEvent()
		.then((e) => {
			if (e) {
				event = wrapEvent(e);
				editUrl = `/article/${draft.encode()}`;
			}
		})
		.catch((e) => {
			console.log('error with content', draft.content);
			console.error(e);
			error = e.message;
		});
	
	const author = $derived(draft.pubkey !== user?.pubkey ? draft.author : null);

	const stats = $derived.by(() => {
		if (!event) return {};
		return {
			"Words": event.content.split(' ').length,
		}
	})

	async function openDraft(e: MouseEvent) {
		e.preventDefault();
		console.log('opening draft', appState.postState);
		appState.postState = await ArticleState.from(draft);
		if (editUrl) {
			goto(editUrl);
		}
	}
</script>

{#if event}
	<a href={editUrl} onclick={openDraft} class="hover:bg-secondary/20 block w-full">
		<Item
			{author}
			byline={"from "}
			title={event.title}
			image={event.image}
			timestamp={draft.created_at}
			tags={event.tags.filter(t => t[0] === 't').map(t => t[1])}
			event={draft}
			{stats}
			onDelete={() => draft.delete()}
		/>
	</a>
{:else}
	<Item
		{author}
		byline={"from "}
		title={error + " " + draft.tagValue('k')}
		timestamp={draft.created_at}
		event={draft}
		onDelete={() => draft.delete()}
	/>
{/if}
