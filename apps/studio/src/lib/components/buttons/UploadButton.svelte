<script lang="ts">
	import { Uploader } from "@highlighter/common";
	import { toast } from "svelte-sonner";
	import { Button, type ButtonVariant } from "../ui/button";
	import type { NDKEvent, NDKSigner } from "@nostr-dev-kit/ndk";
    import { Progress } from "$lib/components/ui/progress/index.js";
	import { ndk } from "@/state/ndk";

    type UploadType = "file" | "image" | "video" | "audio" | "*";

    interface Props {
        variant: ButtonVariant;
        style?: string;
        children: any;
        class?: string;
        type?: UploadType;
        progress?: number | undefined;
        startUpload?: boolean;
        blob?: Blob | undefined;
        videoDuration?: number | void | undefined;
        signer?: NDKSigner | undefined;
        fileInput?: HTMLInputElement | undefined;
        onUploaded?: (url: string, mediaEvent: NDKEvent) => void;
    }

    let {
        variant = "default",
        style = "",
        children,
        class: className = "",
        type = "*",
        progress = $bindable(),
        startUpload = true,
        blob = undefined,
        videoDuration = undefined,
        signer = undefined,
        fileInput = $bindable(),
        onUploaded
    }: Props = $props();

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

        upload('https://nostr.download');

        // dispatch('fileSelected', {
        //     file: blob,
        //     duration: videoDuration,
        // });
    }

    // $: if (blob && startUpload && progress === undefined) {
    //     upload();
    // }

    async function upload(blossomServer: string) {
        progress = 0;
        if (!blob) return;

        const uploader = new Uploader(blob, blossomServer, ndk);
        uploader.signer = signer;
        uploader.onProgress = (p) => progress = p;
        uploader.onUploaded = (url: string) => {
            const mediaEvent = uploader.mediaEvent();
            // dispatch('uploaded', { url, mediaEvent });
            if (onUploaded) {
                onUploaded(url, mediaEvent);
            }
            progress = undefined;
            blob = undefined;
        };
        uploader.onError = (e) => {
            console.error(e);
            toast.error("Failed to upload image: " +e)
        };
        uploader.start();
    }
</script>

<!-- {#if progress === undefined}
{:else}
    <div class="radial-progress min-h-12 min-w-12 text-xs {$$props.progressButton??""}" style="--thickness: 2px; --size: 2.5rem; --value:{progress};">{Math.floor(progress)}%</div>
{/if} -->

<Button {variant} {style} onclick={() => fileInput?.click()} class={className}>
    {@render children()}
    {#if progress}
        <Progress value={progress} />
    {/if}
</Button>

<input
    bind:this={fileInput}
    type="file"
    accept="{type}/*"
    class="hidden"
    id="file"
    onchange={handleFileChange}
/>