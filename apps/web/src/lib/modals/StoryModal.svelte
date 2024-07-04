<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { Hexpubkey, NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { derived } from "svelte/store";
    import ModalShell from "$components/ModalShell.svelte";
	import { closeModal } from "$utils/modal";

    export let pubkey: Hexpubkey;

    const twentyfourhoursago = Math.floor(Date.now() / 1000) - 86400;

    const videos = $ndk.storeSubscribe([
        { kinds: [1063, NDKKind.HorizontalVideo], authors: [pubkey], since: twentyfourhoursago },
    ], { groupable: false });

    const filteredVideos = derived(videos, ($videos) => {
        return $videos.filter(video => video.tagValue("url"));
    });

    let currentVideoLoaded = false;
    let currentVideo = 0;
    let video: NDKEvent | undefined;

    $: video = $filteredVideos[currentVideo];

    function nextVideo() {
        currentVideo++;
        currentVideoLoaded = false;

        if (currentVideo >= $filteredVideos.length) {
            closeModal();
        }
    }
</script>

<ModalShell
    title="Stories"
    class="!p-0 h-screen"
>
    <div class="flex flex-row gap-1 h-5">
        <!-- Indicators of the progress through the stories -->
        {#each $filteredVideos as video}
            <div
                class="min-w-4 grow h-1 bg-muted-foreground"
                style="background-color: {currentVideo >= $filteredVideos.indexOf(video) ? 'white' : 'gray'}"
            />
        {/each}

    </div>

    
    {#if video}
        <div class="w-auto h-auto relative">
            <button
                class="w-full h-full absolute top-0 left-0 z-50"
                on:click|preventDefault={() => currentVideo++}
            />
            <video
                src={video.tagValue("url")}
                class="w-auto h-auto object-cover"
                controlsList="nofullscreen"
                autoplay
                on:canplay={() => console.log("can play")}
                on:loadeddata={() => currentVideoLoaded = true }
                on:abort={nextVideo}
                on:error={nextVideo}
                muted
                on:ended={nextVideo}
            />
        </div>

        {#if currentVideoLoaded && $filteredVideos[currentVideo + 1]}
            <video
                src={$filteredVideos[currentVideo + 1].tagValue("url")}
                class="hidden"
                on:loadeddata={() => console.log("loaded next video")}
                on:abort={() => console.log("aborted from next video")}
            />
        {/if}
    {/if}

</ModalShell>