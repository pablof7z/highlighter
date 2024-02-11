<script lang="ts">
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import VideoCover from "./VideoCover.svelte";
	import TagInput from "./TagInput.svelte";

    export let video: NDKVideo;
    export let videoFile: File | undefined;
</script>

<border class="w-full h-full flex flex-col gap-6">
    <VideoCover bind:video bind:videoFile />

    <section class="settings">
        <TagInput event={video} />
    </section>
</border>
