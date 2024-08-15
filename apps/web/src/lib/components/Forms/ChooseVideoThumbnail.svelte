<script lang="ts">
    import { onMount } from "svelte";
	import { slide } from 'svelte/transition';
	import { Image } from 'phosphor-svelte';
	import { ScrollArea } from '$components/ui/scroll-area';
	import Button from '$components/ui/button/button.svelte';

    export let title: string;
    export let content: string;
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
            mounted = true;
            generate();
        }  finally {
            generatingThumbnails = false;
        }
    });

    let fileUpload: HTMLInputElement;

    $: selectedBlob = selectedThumbnail?.blob;
</script>

<canvas bind:this={canvas} class="hidden"></canvas>

<div class="flex flex-col overflow-hidden gap-4">
    <div class="relative rounded bg-background col-span-2 row-span-2 flex items-stretch justify-stretch">
        {#if generatingThumbnails}
            <div class="flex w-full flex-row items-center justify-center gap-4">
                Generating thumbnails...
                <span class="loading loading-sm"></span>
            </div>
        {/if}

        {#if currentThumbnail ?? selectedThumbnail?.dataUrl}
            <img src={currentThumbnail ?? selectedThumbnail?.dataUrl} class="!w-full md:!h-72 object-cover rounded-xl" />
        {/if}
    </div>

    {#if thumbnails.length > 1}
        <div class="w-full" transition:slide>
            <ScrollArea orientation="horizontal">
                <div class="w-max flex flex-row gap-6">
                {#each thumbnails as thumbnail, index}
                    <button
                        class="h-24 object-cover rounded-xl flex-none opacity-50 transition-all duration-300"
                        class:!opacity-100={selectedIndex === index}
                        on:click={() => selectedIndex = index}
                    >
                        <img src={thumbnail.dataUrl} class="w-full h-full object-cover rounded-xl" alt="" />
                    </button>
                {/each}
                </div>
            </ScrollArea>
        </div>
    {/if}

    <label>
        <Button>
            <Image class="w-8 h-8 mr-2" />
            {#if thumbnails.length > 0}
                or upload an image
            {:else}
                Upload a cover image
            {/if}
            <input type="file" bind:this={fileUpload} id="fileUploader" accept="image/*" class="hidden" on:change={handleFileUpload}>
        </Button>
    </label>
    
</div>