<script lang="ts">
	import { ndk, newToasterMessage, user } from "@kind0/ui-common";
	import { NDKVideo, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { page } from '$app/stores';
	import VideoEditPage from "$components/Editor/VideoEditPage.svelte";
	import { Coins } from "phosphor-svelte";
	import { getTierSelectionFromAllTiers, requiredTiersFor } from "$lib/events/tiers";
	import { debugMode } from "$stores/session";
	import { nonSubscribersPreview, selectedTiers } from "$stores/post-editor";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";

	let dTag: string;

	let video: NDKVideo;
	let teaser: NDKVideo;
	let tiers: Record<string, boolean> = { "Free": true };

	const allTiers = getUserSubscriptionTiersStore();

	$: if (dTag !== $page.params.dTag) {
		dTag = $page.params.dTag;

		$ndk.fetchEvents({
			kinds: [NDKKind.HorizontalVideo], authors: [$user.pubkey], "#d": [dTag]
		}).then(async (events: Set<NDKEvent>) => {
			if (!events.size) {
				newToasterMessage("Video not found", "error");
				return;
			}

			const _video = NDKVideo.from(Array.from(events)[0]);

			const fullId = _video.tagValue("full");
			const previewId = _video.tagValue("preview");
			let otherEvent: NDKEvent | null | undefined = undefined;

			if (fullId || previewId) {
				otherEvent = await $ndk.fetchEvent(fullId ?? previewId!);
			}

			console.log({fullId, previewId, otherEvent});

			if (otherEvent) {
				if (fullId) {
					teaser = _video;
					video = NDKVideo.from(otherEvent);
				} else {
					teaser = NDKVideo.from(otherEvent);
					video = _video;
				}
				$nonSubscribersPreview = true;
			} else {
				video = _video;
				teaser = new NDKVideo($ndk);
				$nonSubscribersPreview = false;
			}

			const videoRequiredTiers = requiredTiersFor(video);
			tiers = {};
			for (const tier of videoRequiredTiers) {
				tiers[tier] = true;
			}

			$selectedTiers = getTierSelectionFromAllTiers($allTiers);
			// set all to false
			for (const tier of Object.keys($selectedTiers)) {
				$selectedTiers[tier].selected = false;
			}
			for (const tier of videoRequiredTiers) {
				$selectedTiers[tier] = { name: tier, selected: true };
			}
		})
	}
</script>

{#key dTag}
	{#if video && teaser}
		<VideoEditPage {video} {teaser} {tiers} />
	{/if}
{/key}

{#if $debugMode}
	{#if video}
		<pre>{JSON.stringify(video.rawEvent(), null, 2)}</pre>
	{/if}
	{#if teaser}
		<pre>{JSON.stringify(teaser.rawEvent(), null, 2)}</pre>
	{/if}
{/if}