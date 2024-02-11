<script lang="ts">
	import VideoUploader from '$components/Forms/VideoUploader.svelte';
	import type { NDKVideo } from '@nostr-dev-kit/ndk';
	import TitleInput from './TitleInput.svelte';

    export let video: NDKVideo;
    export let videoFile: File | undefined;
    let pendingStatus: string | undefined;
    let videoUrl: string | undefined = video.url;

    $: {
        const haveVideo = !!videoFile || !!videoUrl;
        const haveTitle = !!video.title && video.title.length > 0;
    }

    function uploading(e: CustomEvent<{progress: number | string}>) {
        console.log('uploading', e.detail);
        const { progress } = e.detail;

        // if progress is a number
        if (typeof progress === 'number') {
            pendingStatus = `Uploading video ${progress.toFixed(0)}%`;
        } else {
            pendingStatus = "Uploading video";
        }

        if (progress === undefined) {
            pendingStatus = "Video uploaded!";
            setTimeout(() => {
                pendingStatus = undefined;
            }, 1500);
        }
    }

    function uploaded() {
        pendingStatus = "Video uploaded!";
        setTimeout(() => {
            pendingStatus = undefined;
        }, 1500);
    }
</script>

<VideoUploader
    wrapperClass="min-h-[24rem]"
    bind:video
    bind:videoUrl
    bind:videoFile
    thumbnail={video.thumbnail}
    on:uploading={uploading}
    on:uploaded={uploaded}
/>

<TitleInput bind:video />