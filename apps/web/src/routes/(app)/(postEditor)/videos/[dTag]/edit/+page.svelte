<script lang="ts">
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKVideo, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { page } from '$app/stores';
	import VideoEditPage from "$components/Forms/VideoEditPage.svelte";

	let dTag: string;

	let video: NDKVideo;

	$: if (dTag !== $page.params.dTag) {
		dTag = $page.params.dTag;

		$ndk.fetchEvents({
			kinds: [NDKKind.HorizontalVideo], authors: [$user.pubkey], "#d": [dTag]
		}).then(async (events: Set<NDKEvent>) => {
			if (!events.size) {
				newToasterMessage("Video not found", "error");
				return;
			}

			video = NDKVideo.from(Array.from(events)[0]);

			const fullId = video.tagValue("full");
			const previewId = video.tagValue("preview");
			let otherEvent: NDKEvent | null | undefined = undefined;
			let teaser: NDKVideo;

			if (fullId || previewId) {
				otherEvent = await $ndk.fetchEvent(fullId ?? previewId!);
			}

			if (otherEvent && fullId) {
				teaser = video;
				video = NDKVideo.from(otherEvent);
			} else {
				teaser = NDKVideo.from(otherEvent);
			}

		}).catch((e: any) => alert(e))
	}
</script>

{#key dTag}
	{#if video}
		<VideoEditPage {video} {teaser} />
	{/if}
{/key}