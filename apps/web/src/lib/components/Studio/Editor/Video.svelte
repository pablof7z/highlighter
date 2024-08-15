<script lang="ts">
	
    import * as Studio from '$components/Studio';
	import { NDKVideo } from '@nostr-dev-kit/ndk';
	import { Writable } from 'svelte/store';
    import VideoUploader from "./Video/Uploader.svelte";
    import VideoThumbnail from "./Video/Thumbnail.svelte";

    export let state: Writable<Studio.State<"video">>;
    export let video: NDKVideo = $state.video;
    export let videoFile: File | undefined;

    export let done = [ false, false ];
    

    // $: {
    //     const haveVideo = !!videoFile || !!videoUrl;
    //     const haveTitle = !!video.title && video.title.length > 0;
    // }

    const st = "Uploading video";
</script>

<VideoUploader
    {state}
    bind:videoFile
    bind:done={done[0]}
    />
<VideoThumbnail
    {state}
    bind:videoFile
    bind:done={done[1]}
/>