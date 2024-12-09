<script lang="ts">
	import { wrapEvent } from '@highlighter/common';
	import { NDKArticle } from '@nostr-dev-kit/ndk';
	import Item from './Item.svelte';

	const { event } = $props();

	const wrappedEvent = wrapEvent(event);

	const type = wrappedEvent instanceof NDKArticle ? 'article' : 'post';
	const editUrl = `/editor/${type}/${wrappedEvent.encode()}`;
</script>

<Item title={wrappedEvent.title} image={wrappedEvent.image} {editUrl} />
