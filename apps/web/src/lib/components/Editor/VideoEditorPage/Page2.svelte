<script lang="ts">
    import type { NDKVideo } from '@nostr-dev-kit/ndk';
	import { ndk, newToasterMessage, uploadToSatelliteCDN } from '@kind0/ui-common';
	import ChooseVideoThumbnail from '$components/Forms/ChooseVideoThumbnail.svelte';

    export let videoFile: File | undefined = undefined;
    export let video: NDKVideo;
    export let canContinue: boolean;
    export let pendingStatus: string | undefined;
    export let step: number;

    function thumbnailUploaded(e: CustomEvent<string>) {
        const url = e.detail;
        video.thumbnail = url;
        video = video;
    }

    async function upload() {
        const xhr = await uploadToSatelliteCDN($ndk, "image/png");

        xhr.upload.addEventListener('progress', (event) => {
            pendingStatus = "Uploading thumbnail";
        });

        xhr.addEventListener('load', async () => {
            if (xhr.status === 200) {
                const json = JSON.parse(xhr.responseText);
                const {url} = json;
                console.log('uploaded', json, url);
                pendingStatus = undefined;

                video.thumbnail = url;
            } else if (xhr.status === 402) {
                newToasterMessage("Payment required to upload to your Satellite CDN", "error");
                return;
            } else {
                console.error(`Failed to upload image: ${xhr.statusText}`);
                newToasterMessage("Failed to upload image: " +xhr.status, "error")
            }
        });

        xhr.addEventListener('error', (e) => {
            console.log(e);
            console.log(xhr)
            console.error(`Failed to upload image: ${xhr.statusText}`);
            newToasterMessage(`Failed to upload image: ${xhr.statusText}`, "error");
        });

        xhr.send(selectedBlob);
    }

    $: canContinue = !!selectedBlob || !!video.thumbnail;

    let uploadedBlob: Blob | undefined = undefined;
    let selectedBlob: Blob | undefined = undefined;

    $: if (uploadedBlob !== selectedBlob && step === 2) {
        uploadedBlob = selectedBlob;
        upload();
    }
</script>

<div class="flex flex-col gap-4">
    <div class="flex flex-col gap-1">
        <div class="font-semibold text-white text-xl">Cover Image</div>
        <div class="text-white/50 font-thin">
            This image will be shown on the video page and in the feed.
        </div>
    </div>

    <ChooseVideoThumbnail
        {videoFile}
        currentThumbnail={video.thumbnail}
        on:uploaded={thumbnailUploaded}
        title={video.title??"Untitled"}
        duration={video.duration}
        bind:selectedBlob
    />
</div>