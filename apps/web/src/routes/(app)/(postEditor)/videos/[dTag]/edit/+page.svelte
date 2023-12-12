<script lang="ts">
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKArticle, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { page } from '$app/stores';
	import VideoEditPage from "$components/Forms/VideoEditPage.svelte";

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
		<VideoEditPage {article} />
	{/if}
{/key}