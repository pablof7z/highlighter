<script lang="ts">
    import ArticleGrid from "$components/Events/ArticleGrid.svelte";
	import VideoPlayer from "$components/Events/VideoPlayer.svelte";
import Input from "$components/Forms/Input.svelte";
	import VideoIcon from "$icons/VideoIcon.svelte";
	import { isImage, isVideo, isYoutube, youtubeIdFromUrl } from "$utils/media";
	import { Textarea, UploadButton, UrlIcon, ndk } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { Image, Link, Upload, X } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import { slide } from "svelte/transition";

    export let article: NDKArticle = new NDKArticle($ndk, {
        content: "",
    } as NostrEvent);

    article.image ??= "https://cdn.satellite.earth/01a8a5f5162a90fd7e6d3af6bc86d975e08a98f1852864c8ae7d8ba547bad669.png";

    const dispatch = createEventDispatcher();

    let imageBanner: string;
    let contentAreaElement: HTMLTextAreaElement;

	function onImageBannerKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            article.image = imageBanner;
        }
	}

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }

    function uploadedCover(e: CustomEvent<string>) {
        const url = e.detail;
        article.image = url;
    }

    const mTag = article.getMatchingTags("m")[0];

    let videoUrl: string | undefined = mTag && mTag[2];

    function uploadedVideo(e: CustomEvent<string>) {
        videoUrl = e.detail;
        // remove m tag from event
        setVideoUrl(videoUrl);
    }

    function setVideoUrl(url: string) {
        article.removeTag("m");
        article.tags.push(["m", "video", url]);
    }

    let showExistingUrlInput = false;

    function keydownExistingUrl(e: KeyboardEvent) {
        if (e.key === "Enter") {
            showExistingUrlInput = false;
            if (e.target?.value) {
                videoUrl = e.target.value!;
                setVideoUrl(videoUrl!);
            }
        } else if (e.key === "Escape") {
            showExistingUrlInput = false;
        }
    }
</script>

<div class="flex flex-col border-none border-neutral-800 rounded-xl gap-6">
    <div class="bg-base-300 rounded-md w-full h-96 flex flex-col items-center justify-center relative">
        {#if videoUrl}
            <VideoPlayer url={videoUrl} />
        {:else}
            <img src={article.image} alt="" class="absolute top-0 w-full h-full object-cover rounded-xl">
            <div class="z-10 absolute top-0 w-full h-full bg-black/80"></div>
            <div class="max-w-lg w-full z-10 flex flex-col items-center">
                <UploadButton
                    class="button px-8 py-3 w-fit"
                    on:uploaded={uploadedVideo}
                >
                    <Upload class="w-6 h-6" />
                    Upload
                </UploadButton>
                <div class="flex flex-col w-full border-opacity-50 my-2">
                    <div class="divider">OR</div>
                </div>
                {#if !showExistingUrlInput}
                    <button class="button px-8 py-3 w-fit" on:click={() => showExistingUrlInput = true}>
                        <Link class="w-6 h-6 mr-2" />
                        Use existing URL
                    </button>
                {:else}
                    <Input
                        color="black"
                        autofocus={true}
                        class="border rounded-lg focus:ring-0 text-white font-['InterDisplay'] text-lg placeholder:text-white/50 placeholder:font-normal"
                        placeholder="Enter existing URL"
                        on:keydown={keydownExistingUrl}
                    />
                {/if}
            </div>
        {/if}
    </div>

    {#if videoUrl}
        <button class="font-semibold text-white border rounded-lg px-4 py-2 text-sm my-2 self-start" on:click={() => videoUrl = undefined }>Reset</button>
    {/if}

    <div class="flex flex-col">
        <Input
            bind:value={article.title}
            color="black"
            class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] font-semibold placeholder:text-white/50 placeholder:font-normal"
            placeholder="Add a title"
            on:keydown={onTitleKeyDown}
        />

        <Textarea
            bind:value={article.content}
            on:keyup={() => dispatch("contentUpdate", article.content)}
            bind:element={contentAreaElement}
            class="
                !bg-transparent text-base border-none !px-4 -mx-4 rounded-lg text-white
                focus:ring-0 text-opacity-60
                resize-none min-h-[2rem]
            "
            placeholder="Optional description"
        />
    </div>

    <div class="flex flex-row gap-6 items-center">
        {#if article.image}
            <UploadButton class="relative w-72 h-40" on:uploaded={uploadedCover}>
                <img src={article.image} class="absolute top-0 left-0 w-72 h-40 object-cover rounded-xl" />
            </UploadButton>
        {/if}
        <div class="flex flex-col gap-2 w-full h-full items-stretch">
            <div class="font-semibold text-white">Cover Image</div>
            <Input
                bind:value={article.image}
                color="black"
                class="w-full font-normal !text-opacity-50 focus:!text-opacity-100"
                on:keydown={onImageBannerKeyDown}
                placeholder="Cover image URL"
            />

            <div class="flex flex-row items-center text-white gap-4">
                <UploadButton class="button button-primary px-6 bg-base-300" on:uploaded={uploadedCover}>
                    <Image class="w-6 h-6" />
                    Upload
                </UploadButton>
            </div>
        </div>
    </div>
</div>