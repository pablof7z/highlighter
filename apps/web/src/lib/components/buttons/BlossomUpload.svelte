<script lang="ts">
    import { createEventDispatcher } from "svelte";
	import { activeBlossomServer } from "$stores/session";
	import { Uploader } from "$utils/upload";
	import { NDKPrivateKeySigner, NDKSigner } from "@nostr-dev-kit/ndk";
	import { toast } from "svelte-sonner";

    type UploadType = "file" | "image" | "video" | "audio" | "*";

    export let type: UploadType = "*";
    export let progress: number | undefined = undefined;
    export let startUpload = true;
    export let blob: Blob | undefined = undefined;
    export let videoDuration: number | void | undefined = undefined;
    export let signer: NDKSigner | undefined = undefined;

    const dispatch = createEventDispatcher();

    async function getVideoDuration(): Promise<number | void> {
        return new Promise<number | void>((resolve) => {
            if (fileInput.files && fileInput.files[0]) {
                let videoFile = fileInput.files[0];

                // check if the file is a video
                if (videoFile.type.indexOf('video') === -1) {
                    return resolve();
                }

                let videoElement = document.createElement('video');
                videoElement.preload = 'metadata';

                videoElement.onloadedmetadata = function() {
                    resolve(videoElement.duration);

                    // remove video element
                    videoElement.remove();
                    return;
                }

                videoElement.src = URL.createObjectURL(videoFile);
            }
        });
    }

    async function handleFileChange(event: Event) {
        progress = undefined;
        const inputElement = event.target as HTMLInputElement;
        const files = inputElement?.files;
        if (!files || files.length === 0) {
            console.log('No file selected.');
            return;
        }

        blob = files[0];

        getVideoDuration().then((dur) => {
            videoDuration = dur;
        });

        dispatch('fileSelected', {
            file: blob,
            duration: videoDuration,
        });
    }

    $: if (blob && startUpload && progress === undefined) {
        upload();
    }

    async function upload() {
        progress = 0;
        if (!blob) return;

        const uploader = new Uploader(blob, $activeBlossomServer);
        uploader.signer = signer;
        uploader.onProgress = (p) => progress = p;
        uploader.onUploaded = (url: string) => {
            const mediaEvent = uploader.mediaEvent();
            dispatch('uploaded', { url, mediaEvent });
            progress = undefined;
            blob = undefined;
        };
        uploader.onError = (e) => {
            console.error(e);
            toast.error("Failed to upload image: " +e)
        };
        uploader.start();
    }

    export let fileInput: HTMLInputElement | undefined = undefined;
</script>

{#if progress === undefined}
    <button class={$$props.class??""} on:click={() => fileInput.click()}>
        <slot />
    </button>
{:else}
    <div class="radial-progress min-h-12 min-w-12 text-xs {$$props.progressButton??""}" style="--thickness: 2px; --size: 2.5rem; --value:{progress};">{Math.floor(progress)}%</div>
{/if}

<input
    bind:this={fileInput}
    type="file"
    accept="{type}/*"
    class="hidden"
    id="file"
    on:change={handleFileChange}
/>