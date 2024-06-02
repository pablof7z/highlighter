<script lang="ts">
	import VideoPlayer from "$components/Events/VideoPlayer.svelte";
	import ItemHeader from "$components/ItemHeader.svelte";
	import MainWrapper from "$components/Page/MainWrapper.svelte";
	import Box from "$components/PageElements/Box.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { debugMode } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { Avatar, Name, ndk, user } from "@kind0/ui-common";
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { onDestroy, onMount } from "svelte";
	import ItemViewZaps from "./ItemViewZaps.svelte";

    export let video: NDKVideo;
    export let isFullVersion: boolean;

    const author = video.author;

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
    });

    let content = video.content;

    const videoUrl = video.url;
    let editUrl = `/videos/${video.tagValue("d")}/edit`;
</script>

<svelte:head>
    <title>{video.title}</title>
    <meta name="description" content={video.summary} />
    <meta property="og:title" content={video.title} />
    <meta property="og:description" content={video.summary} />
    <meta property="og:thumbnail" content={video.thumbnail} />
    <meta property="og:url" content={`https://highlighter.com/a/${video.encode()}`} />
    <meta property="og:type" content="video" />
</svelte:head>

{#if !isFullVersion && !videoUrl}
    <div class="relative w-full max-h-[70vh]">
        <!-- svelte-ignore a11y-missing-attribute -->
        {#if video.thumbnail}
            <img class="w-full sm:rounded-[20px] max-h-[70vh] h-[30rem] mx-auto object-cover" src={video.thumbnail} />
        {:else}
            <div class="w-full bg-base-300 sm:rounded-xl h-[50vh] mx-auto" />
        {/if}
        <div class="absolute top-0 left-0 w-full h-full bg-black/50 flex flex-col items-center justify-center">
            <UpgradeButton event={video} />
        </div>
    </div>
{:else if videoUrl}
    <div class="w-full flex flex-col items-stretch justify-stretch max-h-[80vh] transition-all duration-100">
        <VideoPlayer title={video.title} url={videoUrl} />
    </div>
{/if}

<div class="flex-col justify-center items-start gap-6 flex overflow-x-hidden max-sm:max-w-[90vw]">
    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
        <div class="flex flex-row w-full justify-between items-center text-white text-2xl font-medium">
            <div>{video.title}</div>
        </div>
        {#if $user?.pubkey === video.pubkey}
            <a href={editUrl} class="button">Edit</a>
        {/if}
        <!-- <div class="flex-row items-start gap-4 flex w-full justify-between">
            <div class="flex flex-row items-center gap-12">
                <EventActionButtons
                    event={video}
                    on:comment
                />

                {#if video.pubkey === $user?.pubkey}
                    <a href={editUrl} class="button">Edit</a>
                {/if}
            </div>
        </div> -->
    </div>
    
    <ItemViewZaps event={video} />
    
    
    {#if content.length > 0}
        <Box class="text-lg font-light leading-8 w-full px-2 overflow-x-auto">
            <EventContent ndk={$ndk} event={video} {content} />
        </Box>
    {/if}
</div>
