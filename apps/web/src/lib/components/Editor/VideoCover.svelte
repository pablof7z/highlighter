<script lang="ts">
    import type { NDKVideo } from '@nostr-dev-kit/ndk';
	import ChooseVideoThumbnail from '$components/Forms/ChooseVideoThumbnail.svelte';
    import createDebug from "debug";
	import { ndk } from '$stores/ndk';
	import { Uploader } from '$utils/upload';
	import { activeBlossomServer } from '$stores/session';

    export let videoFile: File | undefined = undefined;
    export let video: NDKVideo;

    const st = "Uploading thumbnail";

    const debug = createDebug("HL:video-uploader");
    let progress: number | undefined;

    async function upload() {
        if (!selectedBlob) return;

        const uploader = new Uploader(selectedBlob, $activeBlossomServer);
        if (!$status.some((s) => s === st)) $status.push(st);
        uploader.onProgress = (p) => progress = p;
        uploader.onUploaded = (url: string) => {
            const mediaEvent = uploader.mediaEvent();
            progress = undefined;
            selectedBlob = undefined;
            video.thumbnail = url;
            status.update((s) => s.filter((st) => st !== st));
        };
        uploader.onError = (e) => {
            console.error(e);
            toast.error("Failed to upload image: " +e)
            status.update((s) => s.filter((st) => st !== st));
        };
        uploader.start();
    }

    let uploadedBlob: Blob | undefined = undefined;
    let selectedBlob: Blob | undefined = undefined;

    $: if (uploadedBlob !== selectedBlob) {
        uploadedBlob = selectedBlob;
        upload();
    }
</script>

<section class="settings">
    <div class="field">
        <div class="title">Cover Image</div>

        <ChooseVideoThumbnail
            {videoFile}
            currentThumbnail={video.thumbnail}
            title={video.title??"Untitled"}
            content={video.content??""}
            duration={video.duration}
            bind:selectedBlob
        />
    </div>
</section>