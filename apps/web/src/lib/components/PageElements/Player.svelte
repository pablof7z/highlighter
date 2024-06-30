<script lang="ts">
	import { type NDKEvent } from "@nostr-dev-kit/ndk";
	import { Toolbar } from "konsta/svelte";
	import { appMobileView } from "$stores/app";
	import { loadedMedia, loadedMediaStatus, togglePause } from "$stores/media";
	import Button from "$components/ui/button/button.svelte";
	import { Pause, Play } from "phosphor-svelte";

    let paused: boolean;
    let duration = 0;
    let currentTime = 0;

    $: paused = $loadedMediaStatus === "paused";
</script>

{#if $loadedMedia[0]?.mediaUrl}
    {#if $appMobileView}
        <!-- <Toolbar bottom class="hairline-t pt-1 w-full {$$props.containerClass??""} {$$props.class??""}">
        </Toolbar> -->
    {:else}
        <div class="mobile-nav fixed right-0 bottom-0 h-18 items-center flex p-2 bg-background z-[99999999] {$$props.containerClass??""} {$$props.class??""}">
            <Button variant="secondary" on:click={togglePause}>
                {#if paused}
                    <Play size={24} />
                {:else}
                    <Pause size={24} />
                {/if}
            </Button>
            {Math.floor(currentTime)} / {Math.floor(duration)}
            <audio src={$loadedMedia[0].mediaUrl} autoplay bind:paused bind:duration bind:currentTime />
        </div>
    {/if}
{/if}