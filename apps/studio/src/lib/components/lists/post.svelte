<script lang="ts">
	import { wrapEvent } from '@highlighter/common';
	import { NDKArticle, NDKEvent, NDKKind } from '@nostr-dev-kit/ndk';
	import Item from './Item.svelte';
	import { appState } from '@/state/app.svelte';
	import { goto } from '$app/navigation';
	import { ndk } from '@/state/ndk';

	type Props = {
		event: NDKEvent;
	}

	const { event }: Props = $props();

	const wrappedEvent = wrapEvent(event);

	const type = wrappedEvent instanceof NDKArticle ? 'article' : 'post';
	const editUrl = `/${type}/${wrappedEvent.encode()}`;

	function onShare() {
		appState.activeEvent = wrappedEvent;
		goto(`/share`);
	}

	const relatedEvents = ndk.$subscribe([
		{ ...event.filter() }
	])

	const bookmarkKinds = [NDKKind.CurationSet, NDKKind.ArticleCurationSet, NDKKind.BookmarkList];
	const bookmarks = relatedEvents.filter(e => bookmarkKinds.includes(e.kind!));

	const commentKinds = [NDKKind.Text, NDKKind.GenericResponse];
	const comments = relatedEvents.filter(e => commentKinds.includes(e.kind!));

	const reactions = relatedEvents.filter(e => e.kind === NDKKind.Reaction);

	const repostKinds = [NDKKind.Repost, NDKKind.GenericRepost];
	const reposts = relatedEvents.filter(e => repostKinds.includes(e.kind!));

	const zapKinds = [NDKKind.Zap, NDKKind.Nutzap];
	const zaps = relatedEvents.filter(e => zapKinds.includes(e.kind!));

	const stats = $derived.by(() => {
		const statObj: Record<string, number> = {};
		if (bookmarks.length > 0) statObj["Bookmarks"] = bookmarks.length;
		if (comments.length > 0) statObj["Comments"] = comments.length;
		if (reactions.length > 0) statObj["Reactions"] = reactions.length;
		if (reposts.length > 0) statObj["Reposts"] = reposts.length;
		if (zaps.length > 0) statObj["Zaps"] = zaps.length;
		return statObj;
	});
</script>

<Item
	title={wrappedEvent.title}
	image={wrappedEvent.image}
	timestamp={wrappedEvent.published_at}
	{editUrl}
	{onShare}
	event={wrappedEvent}
	stats={stats}
	viewLink={`https://highlighter.com/a/${wrappedEvent.encode()}`}
/>
