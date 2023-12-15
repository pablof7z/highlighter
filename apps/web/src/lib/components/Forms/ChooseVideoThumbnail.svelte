<script lang="ts">
    import { createEventDispatcher, onMount } from "svelte";
	import { ArrowLeft, ArrowRight, Upload } from "phosphor-svelte";
    import { ndk, newToasterMessage, uploadToSatelliteCDN, user } from "@kind0/ui-common";
	import ArticleGrid from "$components/Events/ArticleGrid.svelte";
	import VideoGrid from "$components/Events/VideoGrid.svelte";

    export let title: string;
    export let duration: number | undefined;
    export let videoFile: File | undefined = undefined;
    export let currentThumbnail: string | undefined = undefined;
    export let selectedBlob: Blob | undefined = undefined;

    let processedVideoFile: File | undefined = undefined;

    $: if (videoFile !== processedVideoFile && videoFile && mounted) {
        processedVideoFile = videoFile;
        generate();
    }

    let generatingThumbnails = true;

    let canvas: HTMLCanvasElement;

    type Thumbnail = {
        blob: Blob;
        dataUrl: string;
        url?: string;
        type: string;
        timestamp: number;
    }

    let thumbnails: Thumbnail[] = [];
    let selectedIndex: number | undefined = undefined;
    let selectedThumbnail: Thumbnail | undefined = undefined;
    let mounted = false;

    onMount(() => {
        mounted = true;
    })

    $: if (mounted && selectedIndex !== undefined) {
        selectedThumbnail = thumbnails[selectedIndex];
    }

    function generate() {
        if (!videoFile) return;

        if (!canvas) {
            alert('Canvas not found');
            return;
        }

        const url = URL.createObjectURL(videoFile);
        const videoElement = document.createElement('video');
        const context = canvas.getContext('2d') as CanvasRenderingContext2D;
        let timestamps: number[] = [];
        let currentIndex = 0;

        videoElement.src = url;
        videoElement.addEventListener('loadedmetadata', function() {
            let maxThumbnails = 15;

            // Determine an appropriate number of thumbnails based on video length
            // For very short videos, reduce the number of thumbnails
            const minInterval = 10; // Minimum interval in seconds between thumbnails
            maxThumbnails = Math.min(maxThumbnails, Math.floor(minInterval));

            // Ensure at least one thumbnail for very short videos
            if (maxThumbnails < 1) maxThumbnails = 1;

            const interval = maxThumbnails;

            // Generate 15 timestamps within the first half of the video
            for (let i = 0; i < 15; i++) {
                timestamps.push(interval * i);
            }

            // Seek to the first timestamp
            videoElement.currentTime = timestamps[0];
        });

        videoElement.addEventListener('seeked', function() {
            if (currentIndex >= timestamps.length) {
                return; // Stop when all thumbnails are generated
            }

            canvas.width = videoElement.videoWidth;
            canvas.height = videoElement.videoHeight;
            context.drawImage(videoElement, 0, 0, canvas.width, canvas.height);

            // Optional: Convert the canvas to an image URL or Blob
            const dataUrl = canvas.toDataURL('image/png');
            const blob = dataURLToBlob(dataUrl);

            const thumbnail: Thumbnail = {
                blob,
                dataUrl,
                type: 'image/png',
                timestamp: timestamps[currentIndex],
            };

            thumbnails.push(thumbnail);
            thumbnails = thumbnails;

            selectedIndex ??= 0;

            currentIndex++;
            if (currentIndex < timestamps.length) {
                videoElement.currentTime = timestamps[currentIndex];
            }
        });
    }

    function dataURLToBlob(dataURL: string) {
        const byteString = atob(dataURL.split(',')[1]);
        const mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0];
        const ab = new ArrayBuffer(byteString.length);
        const ia = new Uint8Array(ab);
        for (let i = 0; i < byteString.length; i++) {
            ia[i] = byteString.charCodeAt(i);
        }
        return new Blob([ab], { type: mimeString });
    }

    function handleFileUpload(event: Event) {
        const input = event.target as HTMLInputElement;
        if (!input.files || input.files.length === 0) {
            return;
        }

        const file = input.files[0];
        const reader = new FileReader();

        reader.onload = (e) => {
            const dataUrl = e.target?.result;
            if (typeof dataUrl === 'string') {
                const thumbnail: Thumbnail = {
                    type: file.type,
                    blob: file,
                    dataUrl,
                    url: dataUrl,
                    timestamp: -1 // Indicate this is an uploaded image, not a video timestamp
                };

                thumbnails = [...thumbnails, thumbnail];
                selectedIndex = thumbnails.length - 1;
            }
        };

        reader.readAsDataURL(file);
    }

    onMount(() => {
        try {
            generate();
        }  finally {
            generatingThumbnails = false;
        }
    });

    let fileUpload: HTMLInputElement;

    const videoMock = {
        title,
        thumbnail: "https://i.imgur.com/3Zo7z3u.png",
        duration,
        author: $user,
        tagValue: () => "",
    };

    $: videoMock.thumbnail = currentThumbnail ?? selectedThumbnail?.dataUrl!;
    $: videoMock.title = title ?? "Untitled";

    $: selectedBlob = selectedThumbnail?.blob;
</script>

<canvas bind:this={canvas} class="hidden"></canvas>

{#if generatingThumbnails}
    <div class="flex w-full flex-row items-center justify-center gap-4">
        Generating thumbnails...
        <span class="loading"></span>
    </div>
{/if}

{#if currentThumbnail || selectedIndex !== undefined}
    <div class="flex">
        <VideoGrid
            video={videoMock}
            skipLink={true}
        />
    </div>
{/if}

<div class="flex flex-row gap-4 flex-nowrap overflow-x-auto overflow-y-hidden w-full pb-10">
    {#each thumbnails as thumbnail, index}
        <button
            class="object-cover rounded-xl flex-none opacity-50"
            class:opacity-100={selectedIndex === index}
            on:click={() => selectedIndex = index}
        >
            <img src={thumbnail.dataUrl} class="w-full h-full object-cover rounded-xl" />
        </button>
    {/each}

    {#if !selectedThumbnail}
        <button class="image-placeholder w-fit h-full object-cover rounded-xl bg-base-300" on:click={() => fileUpload.click()} />
    {/if}
</div>

<div class="flex flex-row items-center">
    <div class="text-sm flex flex-col gap-1 items-center w-full">
        <div class="flex flex-row w-full justify-between gap-2">
            <label class="button button-primary text-sm cursor-pointer">
                {#if thumbnails.length > 0}
                    or upload an image
                {:else}
                    Upload a cover image
                {/if}
                <input type="file" bind:this={fileUpload} id="fileUploader" accept="image/*" class="hidden" on:change={handleFileUpload}>
            </label>
        </div>
    </div>
</div>

<style lang="postcss">
    img, .image-placeholder {
        @apply w-[321px] h-[180px] object-cover;
    }
</style>