<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	import { NDKArticle } from "@nostr-dev-kit/ndk";
	import ShareImage from "./Event/ShareImage.svelte";
	import { toBlob } from "html-to-image";
	import { Uploader } from "$utils/upload";
	import { activeBlossomServer } from "$stores/session";
	import { newToasterMessage } from '$stores/toaster';

    export let article: NDKArticle;
    export let status: "initial" | "uploading" | "uploaded" | "error" = "initial";
    export let progress: number = 0;
    export let publishMedia: boolean = false;
    export let url: string | undefined = undefined;
    export let forceGenerate: boolean = false;
    export let forceUpload: boolean = false;

    /**
     * Copies over the `t` tags from the article to the media event
     */
    export let addEventTagsToMedia = false;

    const dispatcher = createEventDispatcher();

    let shareImageEl: HTMLElement;
    let blob: Blob | null = null;

    async function generate() {
        if (!shareImageEl) return;

        blob = await toBlob(shareImageEl);
        if (!blob) throw new Error("Failed to convert image to blob");
    }

    async function upload() {
        if (!blob) return;
        const uploader = new Uploader(blob, $activeBlossomServer);
        uploader.onProgress = (p) => {
            console.log("Progress", p);
            progress = p;
            dispatcher('progress', p);
        };
        uploader.onUploaded = async (u) => {
            url = u;
            const mediaEvent = uploader.mediaEvent();

            mediaEvent.tag(article);

            // Add tags from the article to the media event
            if (addEventTagsToMedia) {
                for (const tag of article.getMatchingTags("t")) {
                    mediaEvent.tags.push(tag);
                }
            }
            
            if (mediaEvent && publishMedia) {
                await mediaEvent.sign();
                await mediaEvent.publish();
            }
            
            dispatcher('uploaded', {url, mediaEvent });
            status = "uploaded";
        };
        uploader.onError = (e) => {
            newToasterMessage("Failed to upload image: " + e, "error");
            dispatcher('error', e);
            status = "error";
        };
        uploader.start();
        status = "uploading";
    }

    // If we've been instructed to generate by the parent
    // controller and we have all we need, let's proceed
    $: if (
        forceGenerate &&
        shareImageEl &&
        status === "initial"
    ) {
        generate();
    }

    $: if (forceUpload && blob && status === "initial") {
        upload();
    }
</script>

<ShareImage {article}  bind:node={shareImageEl}>
    <slot />
</ShareImage>