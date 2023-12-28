<script lang="ts">
	import VideoPlayer from "$components/Events/VideoPlayer.svelte";
	import EventActionButtons from "$components/buttons/EventActionButtons.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { requiredTiersFor } from "$lib/events/tiers";
	import { debugMode } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { addReadReceipt } from "$utils/read-receipts";
	import { ndk, user } from "@kind0/ui-common";
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Lock } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";

    export let video: NDKVideo;
    const author = video.author;

    onMount(() => {
        startUserView(author);
        addReadReceipt(video);
    });

    onDestroy(() => {
        userSubscription?.unref();
    });

    const isTeaser = !!video.tagValue("full");

    let content = video.content;

    const videoUrl = video.url;
    let editUrl = `/videos/${video.tagValue("d")}/edit`;

    const requiredTier = requiredTiersFor(video)[0];
</script>

<svelte:head>
    <title>{video.title}</title>
    <meta name="description" content={video.summary} />
    <meta property="og:title" content={video.title} />
    <meta property="og:description" content={video.summary} />
    <meta property="og:thumbnail" content={video.thumbnail} />
    <meta property="og:url" content={`https://getfaaans.com/${video.encode()}`} />
    <meta property="og:type" content="video" />
</svelte:head>

<div class="flex flex-col gap-6 w-full">
    {#if videoUrl}
        <div class="w-full flex flex-col items-stretch justify-stretch max-h-[80vh] transition-all duration-100">
            <VideoPlayer title={video.title} url={videoUrl} />
        </div>
    {:else if video.thumbnail && isTeaser}
        <div class="relative w-full max-h-[70vh]">
            <!-- svelte-ignore a11y-missing-attribute -->
            <img class="w-fit rounded-[20px] max-h-[70vh] mx-auto" src={video.thumbnail} />
            <div class="absolute top-0 left-0 w-full h-full bg-black/50 flex flex-col items-center justify-center">
                <UpgradeButton event={video} />
            </div>
        </div>
    {/if}

    <div class="flex-col justify-start items-center gap-10 flex w-full flex-grow">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start gap-6 flex">
                    <div class="self-stretch flex-col justify-start items-start gap-6 flex">
                        <div class="self-stretch text-white text-2xl font-medium">
                            <div class="flex flex-row w-full justify-between items-center">
                                <div>{video.title}</div>

                                {#if isTeaser}
                                    <UpgradeButton class="!bg-transparent text-white text-xs" event={video} />
                                {/if}
                            </div>
                        </div>
                        <div class="flex-col justify-start items-start gap-4 flex w-full">
                            <div class="flex flex-row items-center gap-12 w-full">
                                <EventActionButtons
                                    event={video}
                                    on:comment
                                />

                                {#if video.pubkey === $user?.pubkey}
                                    <a href={editUrl} class="button">Edit</a>
                                {/if}
                            </div>
                            <div class="text-white text-opacity-60 text-sm font-normal leading-[21px]">32 responses  108 boosts</div>
                        </div>
                    </div>
                    <div class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-7 w-full">
                        <EventContent ndk={$ndk} event={video} {content} />
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

{#if $debugMode}
    <pre>{JSON.stringify(video.rawEvent(), null, 4)}</pre>
{/if}