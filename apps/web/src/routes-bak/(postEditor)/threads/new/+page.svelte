<script lang="ts">
	import { page } from "$app/stores";
	import { drafts, type DraftItem } from "$stores/drafts";
	import { NDKKind } from "@nostr-dev-kit/ndk";
	import currentUser from "$stores/currentUser";
	import { Thread } from '$utils/thread.js';
	import ThreadEditor from "$components/Editor/ThreadEditor/ThreadEditor.svelte";
	import { currentDraftItem } from "$stores/post-editor";
	import { ndk } from "$stores/ndk";
	import { newToasterMessage } from "$stores/toaster";

	const draftId = $page.url.searchParams.get("draft") || undefined;
	let draftItem: DraftItem | undefined = undefined;
	let thread: Thread;

	if (draftId) {
		draftItem = $drafts.find(d => d.id === draftId);

		if (!draftItem) {
			newToasterMessage("Draft not found", "error");
		} else {
			const checkpoints = JSON.parse(draftItem.checkpoints) as DraftItem["checkpoints"];
			let checkpoint = checkpoints.find(c => c.manuallySaved);
			checkpoint = checkpoints[0];

			const payload = checkpoint?.data;
			thread = Thread.deserialize(payload, $currentUser!, $ndk);
		}
	}

	$currentDraftItem = draftItem;

	thread ??= new Thread(NDKKind.Text, $currentUser!, $ndk);
</script>

<svelte:head>
	<title>New Thread</title>
</svelte:head>

<ThreadEditor {thread} bind:draftItem={$currentDraftItem} />