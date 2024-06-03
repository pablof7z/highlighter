<script lang="ts">
    import type { NDKVideo } from '@nostr-dev-kit/ndk';
    import { status } from '$stores/post-editor';
	import ChooseVideoThumbnail from '$components/Forms/ChooseVideoThumbnail.svelte';
    import createDebug from "debug";

    export let videoFile: File | undefined = undefined;
    export let video: NDKVideo;

    const st = "Uploading thumbnail";

    const debug = createDebug("HL:video-uploader");

    function thumbnailUploaded(e: CustomEvent<string>) {
        const url = e.detail;
        video.thumbnail = url;
        video = video;
    }

    async function upload() {
        if (!selectedBlob) return;

        const xhr = new XMLHttpRequest();

        xhr.upload.addEventListener('progress', (event) => {
            // if st is not in status, add it
            if (!$status.some((s) => s === st)) $status.push(st);
        });

        xhr.addEventListener('load', async () => {
            if (xhr.status >= 200 && xhr.status <= 202) {
                const json = JSON.parse(xhr.responseText);
                const {url} = json;

                // remove from status
                status.update((s) => s.filter((st) => st !== st));

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

        try {
            const res = await nip96Upload(xhr, $ndk, selectedBlob, "nostr.build");
            video.thumbnail = res.nip94_event?.tags.find(t => t[0] === "url")?.[1];
            debug(video.thumbnail);
        } catch (e) {
            console.error(e);
            newToasterMessage(`Failed to upload image: ${e}`, "error");
        }
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
            on:uploaded={thumbnailUploaded}
            title={video.title??"Untitled"}
            content={video.content??""}
            duration={video.duration}
            bind:selectedBlob
        />
    </div>
</section>