<script lang="ts">
	import { Info } from "phosphor-svelte";
    import Input from '$components/ui/input/input.svelte';
    import VideoPlayer from "$components/Events/VideoPlayer.svelte";
	import type { NDKVideo } from "@nostr-dev-kit/ndk";
	import ImageIcon from "$icons/ImageIcon.svelte";
	import VideoUploader from "$components/Forms/VideoUploader.svelte";
	import ItemHeader from "$components/ItemHeader.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { makePublicAfter, previewExtraContent, status } from "$stores/post-editor";
	import { slide } from "svelte/transition";
	import MakePublicAfter from "$components/Editor/Audience/MakePublicAfter.svelte";
	import currentUser from "$stores/currentUser";
	import ContentEditor from "$components/Forms/ContentEditor.svelte";

    export let video: NDKVideo;
    export let teaser: NDKVideo;
    export let authorUrl: string;

    let previewContentReadLink: string;
    const domain = "https://highlighter.com";
    let authorLink = `${domain}${authorUrl}`;
    previewContentReadLink = `Support my work on my Highlighter page: ${authorLink}`;

    $previewExtraContent ??= { before: undefined, after: previewContentReadLink};

    let teaserUrl: string | undefined = undefined;

    $: if ($currentUser) {
        teaser.pubkey = $currentUser.pubkey;
        teaser.author = $currentUser;
    }

    function teaserUploaded(e: CustomEvent<{url: string}>): void {
        teaserUrl = e.detail.url;
        teaser.url = teaserUrl;
        showUploadTrailer = false;

        $status = $status.filter((s) => s !== "Uploading teaser");

        // onUploaded(e);
	}

    let showUploadTrailer = false;

    $previewExtraContent ??= { before: undefined, after: previewContentReadLink};

    $: if (Number($makePublicAfter) > 0) {
        $previewExtraContent!.before = makePublicNotice();
    }

    function makePublicNotice() {
        return `This is a subscribers-first video. The full version will be made public in ${$makePublicAfter} days.`;
    }

    function teaserUploading() {
        $status.push("Uploading teaser");
    }
</script>

<div class="flex flex-col w-full p-6 bg-foreground/5 rounded">
    <div class="flex flex-row justify-between items-center w-full">
        <h3 class="text-foreground text-sm flex flex-row items-center">
            <Info class="w-4 h-4 text-info inline mr-2" />
            This is how your video will look to non-subscribers
        </h3>

        <button class="button" on:click={() => { showUploadTrailer = !showUploadTrailer }}>
            <ImageIcon class="w-6 h-6" />
            Upload a trailer
        </button>
    </div>

    {#if showUploadTrailer}
        <VideoUploader
            wrapperClass="min-h-[12rem]"
            bind:video={teaser}
            bind:videoUrl={teaserUrl}
            on:uploading={teaserUploading}
            on:uploaded={teaserUploaded}
        />
    {/if}
</div>

<MakePublicAfter />

{#if video && $currentUser}
    <div class="mockup-window flex items-start justify-start border border-border w-full mt-10">
        <div class="p-6 w-full flex flex-col gap-6">
            {#key teaserUrl}
                <ItemHeader item={teaser} />

                {#if !teaserUrl}
                    <div class="relative w-full max-h-[70vh] pointer-events-none">
                        <!-- svelte-ignore a11y-missing-attribute -->
                        {#if teaser.thumbnail}
                            <img class="w-full rounded-[20px] h-[30rem] mx-auto object-cover" src={teaser.thumbnail} />
                        {:else}
                            <div class="w-full bg-foreground/20 rounded-xl h-[30vh] mx-auto" />
                        {/if}
                        <div class="absolute top-0 left-0 w-full h-full bg-black/50 flex flex-col items-center justify-center">
                            <UpgradeButton event={teaser} />
                        </div>
                    </div>
                {:else}
                    <div class="w-full flex flex-col items-stretch justify-stretch max-h-[80vh] transition-all duration-100">
                        <div class="w-full flex flex-col items-stretch justify-stretch max-h-[80vh] transition-all duration-100">
                            <VideoPlayer title={teaser.title} url={teaserUrl} />
                        </div>
                    </div>
                {/if}

                <div class="flex flex-col mt-4">
                    <Input
                        bind:value={teaser.title}
                        color="black"
                        class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-foreground font-['InterDisplay'] font-semibold placeholder:text-foreground/50 placeholder:font-normal"
                        placeholder="Add a title"
                    />

                    {#if Number($makePublicAfter) > 0}
                        <div class="flex flex-col justify-stretch w-full" transition:slide>
                            <ContentEditor
                                bind:value={$previewExtraContent.before}
                                class="
                                    !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                                    focus:ring-0
                                    resize-none min-h-[5rem] text-muted-foreground
                                    {$$props.textareaClass??""}
                                "
                            />
                            <div class="border-b border-neutral-700 pb-2"></div>
                        </div>
                    {/if}

                    <ContentEditor
                        bind:value={teaser.content}
                        class="
                            !bg-transparent border-none !px-4 -mx-4 rounded-lg text-foreground
                            focus:ring-0 text-opacity-60
                            resize-none min-h-[2rem] text-lg
                        "
                        placeholder="Description"
                    />
                </div>

                <div class="border-t border-neutral-700 pt-4"></div>
                <ContentEditor
                    toolbar={false}
                    bind:value={$previewExtraContent.after}
                    class="
                        !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                        focus:ring-0
                        resize-none min-h-[5rem]  text-muted-foreground
                        {$$props.textareaClass??""}
                    "
                    placeholder="Add a call to action or a link to your Highlighter page"
                />
            {/key}
        </div>
    </div>
{/if}
