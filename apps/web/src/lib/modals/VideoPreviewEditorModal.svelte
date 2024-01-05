<script lang="ts">
    import { LockSimple } from "phosphor-svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import VideoUploader from "$components/Forms/VideoUploader.svelte";
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import { randomVideoThumbnail } from "$utils/skeleton";
	import { closeModal } from "svelte-modals";

    export let video: NDKVideo;
    export let teaserUrl: string | undefined = undefined;
    export let teaser: NDKVideo;
    export let onUploaded: (url: string) => void;

    // video.thumbnail = randomVideoThumbnail();

    let useTrailer = !!video.tagValue("preview");

    function teaserUploaded(e: CustomEvent<{url: string}>): void {
        teaserUrl = e.detail.url;
        onUploaded(e);
	}

    let container: HTMLDivElement;

    function onShowTrailer() {
        // Make container stay the same height and width
        container.style.height = `${container.offsetHeight}px`;
        container.style.width = `${container.offsetWidth}px`;

        useTrailer = !useTrailer;
    }
</script>

<ModalShell color="black">
    <div class="flex flex-col gap-1 items-center w-full">
        <div class="font-semibold text-white text-3xl">Teaser Preview</div>
        <div class="text-neutral-500 font-light leading-loose text-center">
            This is how your teaser will look like to non-subscribers. <br>Upload a trailer to entice people to subscribe.
        </div>
    </div>

    <div class="flex flex-row gap-6 min-h-[12rem]" bind:this={container}>
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

    <div class="grid grid-flow-col gap-10 items-center justify-end w-full">
        <button class="btn btn-ghost px-10 py-3 text-sm" on:click={closeModal}>
            Close
        </button>
        <button class="button text-sm px-10 py-3" on:click={onShowTrailer}>
            Upload trailer
        </button>
    </div>
</ModalShell>