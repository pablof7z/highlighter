<script lang="ts">
	import ContentToolbar from '$components/Content/Toolbar.svelte';
    import { NDKUserProfile, NDKVideo } from "@nostr-dev-kit/ndk";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import VideoPlayer from "$components/Events/VideoPlayer.svelte";
	import { HeaderShell } from "..";
	import ItemViewZaps from "$components/Event/ItemView/ItemViewZaps.svelte";
	import { page } from '$app/stores';
	import { addHistory } from '$stores/history';
	import { layout } from '$stores/layout';
	import { title } from 'process';
	import { onMount } from 'svelte';
	import { Footer } from '../Article';
	import TopHeader from '../TopHeader.svelte';
	import { getEventUrl } from '$utils/url';

    export let video: NDKVideo;
    export let isPreview = false;
    export let isFullVersion = true;
    export let userProfile: NDKUserProfile | undefined | null;
    export let authorUrl: string;

    let el: HTMLDivElement;

    const videoUrl = video.url;

    let hasZaps = false;

    onMount(() => {
        addHistory({ category: "Watch", title, url: $page.url.toString() })
    })

    let image: string | undefined;

    $layout.sidebar = false;

    $layout.footer = {
        component: Footer,
        props: { video }
    }

    $: {
        image = video.thumbnail
        if (!image && !isPreview) image ??= userProfile?.image;
    }

    $layout.header = {
        component: TopHeader,
        props: { event: video, userProfile, authorUrl }
    }
    if (video.title) $layout.title = video.title;
</script>

<HeaderShell
    isPreview={isPreview}
    maxImageHeight={"h-full"}
    userProfile={userProfile}
    authorUrl={authorUrl}
    skipSummary={true}
    skipImage={false}
    event={video}
    title={video.title}
    zaps={hasZaps}
>
    <svelte:fragment slot="image">
        {#if !isFullVersion && !videoUrl}
            <div class="relative w-full max-h-[70vh]">
                <!-- svelte-ignore a11y-missing-attribute -->
                {#if video.thumbnail}
                    <img class="w-full sm:rounded-[20px] max-h-[70vh] h-[30rem] mx-auto object-cover" src={video.thumbnail} />
                {:else}
                    <div class="w-full bg-foreground/20 sm:rounded-xl h-[50vh] mx-auto" />
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
    </svelte:fragment>

    <div slot="zaps">
        {#if !isPreview}
            <ItemViewZaps event={video} bind:hasZaps class="py-3 responsive-padding" />
        {/if}
    </div>

    <div slot="toolbar" class="py-3">
        {#if !isPreview}
            <ContentToolbar
                event={video}
                {authorUrl}
                navOptions={
                    [{ name: "Video", href: getEventUrl(video, authorUrl) },]
                }
            />
        {/if}
    </div>

    <slot />
</HeaderShell>


<div class="break-inside max-sm:ml-4 max-sm:mr-12 relative" bind:this={el}>
    
</div>