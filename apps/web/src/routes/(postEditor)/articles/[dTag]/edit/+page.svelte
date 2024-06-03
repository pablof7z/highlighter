<script lang="ts">
	import { NDKArticle, NDKEvent, NDKKind, NDKList, NDKRelaySet, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { page } from '$app/stores';
	import ArticleEditPage from '$components/Editor/ArticleEditPage.svelte';

	let dTag: string;

	let article: NDKArticle;

	$: if (dTag !== $page.params.dTag) {
		dTag = $page.params.dTag;

		$ndk.fetchEvents({
			kinds: [NDKKind.Article], authors: [$user.pubkey], "#d": [dTag]
		}).then((events: Set<NDKEvent>) => {
			if (!events.size) {
				newToasterMessage("Article not found", "error");
				return;
			}

			article = NDKArticle.from(Array.from(events)[0]);
		}).catch((e: any) => alert(e))
	}
</script>

{#key dTag}
	{#if article}
		<ArticleEditPage {article} />
	{/if}
{/key}