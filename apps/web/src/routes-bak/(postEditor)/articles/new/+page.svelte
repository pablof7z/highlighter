<script lang="ts">
	import { page } from "$app/stores";
	import { drafts, type DraftItem, type ArticleCheckpoint, DraftCheckpoint } from "$stores/drafts";
	import ArticleEditPage from "$components/Editor/ArticleEditPage.svelte";
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import { nonSubscribersPreview } from "$stores/post-editor";
	import { ndk } from "$stores/ndk";
	import { newToasterMessage } from "$stores/toaster";

    let article = new NDKArticle($ndk);
	let preview = new NDKArticle($ndk);

	$nonSubscribersPreview = true;

	const draftId = $page.url.searchParams.get("draft") || undefined;
	let draftItem: DraftItem | undefined;

	if (draftId) {
		draftItem = $drafts.find(d => d.id === draftId);

		if (!draftItem) {
			newToasterMessage("Draft not found", "error");
		} else {
			const checkpoints = JSON.parse(draftItem.checkpoints) as DraftCheckpoint[];
			let checkpoint = checkpoints.find(c => c.manuallySaved);
			checkpoint = checkpoints[0];

			const payload = checkpoint?.data as ArticleCheckpoint;

			article = new NDKArticle($ndk, JSON.parse(payload.event));
			try {
				preview = new NDKArticle($ndk, JSON.parse(payload.preview));
			} catch {}
		}
	}
</script>

<svelte:head>
	<title>New article</title>
</svelte:head>

<ArticleEditPage {article} {preview} {draftItem} />
