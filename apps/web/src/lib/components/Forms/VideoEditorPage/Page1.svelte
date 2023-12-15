<script lang="ts">
    import Input from '../Input.svelte';
	import { Textarea } from '@kind0/ui-common';
	import type { NDKVideo } from '@nostr-dev-kit/ndk';
	import VideoUploader from '../VideoUploader.svelte';
    import { createEventDispatcher } from 'svelte';

    export let canContinue: boolean;
    export let video: NDKVideo;
    export let videoFile: File | undefined;
    export let pendingStatus: string | undefined;
    export let step: number;

    const dispatch = createEventDispatcher();

    let videoUrl: string | undefined = video.url;
    let contentAreaElement: HTMLTextAreaElement;

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }

    $: {
        const haveVideo = videoFile || videoUrl;
        const haveTitle = video.title && video.title.length > 0;
        canContinue = haveVideo && haveTitle;
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

    let title: string;

    function onTitleChange() {
        video.title = title;
        video = video;
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

<div class="flex flex-col mt-4">
    <Input
        bind:value={title}
        color="black"
        class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] font-semibold placeholder:text-white/50 placeholder:font-normal"
        placeholder="Add a title"
        on:keydown={onTitleKeyDown}
        on:change={onTitleChange}
    />

    <Textarea
        bind:value={video.content}
        on:keyup={() => dispatch("contentUpdate", video.content)}
        bind:element={contentAreaElement}
        class="
            !bg-transparent border-none !px-4 -mx-4 rounded-lg text-white
            focus:ring-0 text-opacity-60
            resize-none min-h-[2rem] text-lg
        "
        placeholder="Description"
    />
</div>