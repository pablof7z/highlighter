<script lang="ts">
	import VideoEditPage from "$components/Editor/VideoEditPage.svelte";
	import { nonSubscribersPreview } from "$stores/post-editor";
	import { ndk } from "@kind0/ui-common";
	import { NDKVideo } from "@nostr-dev-kit/ndk";

    let video = new NDKVideo($ndk);
	let teaser = new NDKVideo($ndk);

	$nonSubscribersPreview = true;
</script>

<VideoEditPage {video} {teaser} />
