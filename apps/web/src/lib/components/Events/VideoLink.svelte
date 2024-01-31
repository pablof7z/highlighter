<script lang="ts">
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import ItemLink from "./ItemLink.svelte";
	import { niceDuration } from "$utils/video";

    export let video: NDKVideo;
    export let grid = false;
    export let skipAuthor = false;
    export let skipLink = false;
</script>

<ItemLink
    event={video}
    {grid}
    {skipAuthor}
    {skipLink}
    image={video.thumbnail}
    title={video.title}
    description={video.content}
    durationTag={video.duration ? niceDuration(video.duration) : undefined}
/>
