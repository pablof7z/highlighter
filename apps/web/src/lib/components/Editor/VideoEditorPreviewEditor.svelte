<script lang="ts">
	import { LockSimple } from "phosphor-svelte";
	import VideoUploader from "../Forms/VideoUploader.svelte";
	import type { NDKVideo } from "@nostr-dev-kit/ndk";

    export let video: NDKVideo;
    export let teaserUrl: string | undefined = undefined;
    export let teaser: NDKVideo;
    export let wideDistribution: boolean;

    let useTrailer = !!video.tagValue("preview");

    function teaserUploaded(e: CustomEvent<{url: string}>): void {
        teaserUrl = e.detail.url;
        wideDistribution = true;
	}
</script>

<div class="flex flex-col gap-1">
    <div class="font-semibold text-white text-xl">Teaser Preview</div>
    <div class="text-white/50 font-thin">
        This is how your teaser will look like to non-subscribers.
    </div>
</div>
<div class="flex flex-row gap-6">
    {#if !useTrailer}
        <div class="relative mx-auto max-w-lg flex-none">
            <!-- svelte-ignore a11y-missing-attribute -->
            <img class="w-full rounded-[20px] object-cover object-top" src={video.thumbnail} />
            <div class="absolute top-0 left-0 w-full h-full bg-black/50 flex flex-col items-center justify-center">
                <button class="button px-4 py-3 scale-75 whitespace-nowrap">
                    <LockSimple class="w-6 h-6 ml-2" />
                    Become a fan to unlock
                </button>
            </div>
        </div>
    {:else}
        <VideoUploader
            wrapperClass="min-h-[12rem]"
            bind:video={teaser}
            bind:videoUrl={teaserUrl}
            on:uploaded={teaserUploaded}
        />
    {/if}
</div>