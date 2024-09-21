<script lang="ts">
	import VideoPlayer from "$components/Events/VideoPlayer.svelte";
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { Button } from "$components/ui/button";
	import Input from "$components/ui/input/input.svelte";
	import type { NDKTag, NDKVideo } from "@nostr-dev-kit/ndk";
	import { Upload, Link } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

    export let video: NDKVideo;
    export let videoUrl: string | undefined = undefined;
    export let thumbnail: string | undefined = undefined;
    export let videoFile: File | undefined = undefined;

    const dispatch = createEventDispatcher();
    let uploadProgress: number | undefined;
    let showExistingUrlInput = false;
    let startUpload = false;

    function videoSelected(e: CustomEvent<{file: File}>) {
        const {file} = e.detail;
        if (!file) return;

        videoFile = file;

        startUpload = true;

        dispatch("uploading", { progress: 'starting' });
    }

    $: if (videoFile && uploadProgress === undefined) {
        dispatch("uploading", { progress: uploadProgress});
    }

    function uploadedVideo(e: CustomEvent<{nip94: NDKTag[], url: string}>) {
        const { nip94, url } = e.detail;
        const tags = nip94;
        videoUrl = url;

        if (tags) {
            const oldTags = video.tags as NDKTag[];
            const newTagsMap = new Map(tags.map(tag => [tag[0], tag]));
            const oldTagsMap = new Map(oldTags.map(tag => [tag[0], tag]));
            const mergedTags = new Map([...oldTagsMap, ...newTagsMap]);
            video.tags = Array.from(mergedTags.values());
        } else {
            video.url = url;
        }

        dispatch("uploaded", { tags, url });
    }

    function blurExistingUrl(e: FocusEvent) {
        showExistingUrlInput = false;
        if (e.target?.value) {
            videoUrl = e.target.value!;
            video.url = videoUrl;
            dispatch("uploaded", { url: videoUrl });
        }
    }

    function keydownExistingUrl(e: KeyboardEvent) {
        if (e.key === "Enter") {
            showExistingUrlInput = false;
            if (e.target?.value) {
                videoUrl = e.target.value!;
                video.url = videoUrl;
                dispatch("uploaded", { url: videoUrl });
            }
        } else if (e.key === "Escape") {
            showExistingUrlInput = false;
        }
    }

    function onPaymentRequired() {
        startUpload = false;
    }
</script>

<div class="bg-secondary rounded-md w-full flex flex-col items-center justify-center relative {$$props.wrapperClass}">
    {#if videoUrl}
        <VideoPlayer url={videoUrl} />
    {:else}
        {#if thumbnail}
            <img src={thumbnail} alt="" class="absolute top-0 w-full h-full object-cover rounded-xl">
        {:else}
            <div class="absolute bg-white/50 w-full h-full rounded-xl" />
        {/if}
        {#if uploadProgress !== undefined}
            <div class="h-2 bg-accent bottom-0 absolute z-30 left-0 transition-all duration-300" style="width: {uploadProgress}%;"></div>
            <div class="h-2 bg-foreground/20 w-full bottom-0 absolute z-20"></div>
        {/if}

        <div class="z-10 absolute top-0 w-full h-full bg-black/80"></div>
        <div class="max-w-lg w-full z-10 flex flex-col items-center">
            <BlossomUpload
                class="px-8 py-3 w-fit"
                progressClass="h-10 w-10"
                bind:progress={uploadProgress}
                type="video"
                on:uploaded={uploadedVideo}
                on:fileSelected={videoSelected}
                on:paymentRequired={onPaymentRequired}
                {startUpload}
            >
                <Button variant="default" class="px-8 py-3  w-full flex sm:flex-col max-sm:justify-start justify-center items-center gap-2 whitespace-nowrap !h-fit">
                    <Upload class="w-8 h-8" />
                    Upload
                </Button>
            </BlossomUpload>
            <div class="flex flex-col w-full border-opacity-50 my-2 text-center text-muted-foreground">
                OR
            </div>
            {#if !showExistingUrlInput}
                <button class="text-foreground flex px-8 w-fit whitespace-nowrap" on:click={() => showExistingUrlInput = true}>
                    <Link class="w-6 h-6 mr-2" />
                    Use existing URL
                </button>
            {:else}
                <Input
                    autofocus={true}
                    class="text-xs w-[20rem]"
                    placeholder="Enter existing URL"
                    on:keydown={keydownExistingUrl}
                    on:blur={blurExistingUrl}
                />
            {/if}
        </div>
    {/if}

    {#if videoUrl}
        <button class="font-semibold text-foreground border rounded-lg px-4 py-2 text-sm my-2 self-start absolute top-2 right-2 z-50" on:click={() => videoUrl = undefined }>Reset</button>
    {/if}
</div>
