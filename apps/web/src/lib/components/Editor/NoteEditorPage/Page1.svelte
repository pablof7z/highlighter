<script lang="ts">
	import { isImage, isVideo } from "$utils/media";
	import { Textarea, UploadButton } from "@kind0/ui-common";
	import type { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";
	import { Image, X } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    export let note: NDKEvent;
    export let uploadedFiles: string[];

    function uploaded(e: CustomEvent<{url: string, tags: NDKTag[]}>) {
        const {url, tags} = e.detail;
        console.log(e.detail);
        if (url) {
            uploadedFiles.push(url);
            uploadedFiles = uploadedFiles;
        } else {
            console.error("Failed to upload file");
        }
    }
</script>

<div class="">
    <div class="w-full">
        <Textarea
            bind:value={note.content}
            autofocus={true}
            class="w-full sm:rounded-xl max-sm:border-none flex-grow font-normal text-lg leading-normal !bg-transparent !border-base-300 text-neutral-400 p-6"
            placeholder="Write your note here..."
        />

        <div class="flex flex-col gap-4 max-sm:px-4">
            <div class="flex flex-row items-center text-white gap-4">
                <UploadButton class="button button-primary px-4 bg-base-300" on:uploaded={uploaded}>
                    <Image class="w-6 h-6" />
                </UploadButton>
                Attachments
            </div>

            {#if uploadedFiles.length > 0}
                <div class="grid grid-flow-col overflow-x-auto w-full items-start justify-start gap-8 attachments pb-6" transition:slide>
                    {#each uploadedFiles as url}
                        <div class="relative w-72 h-40 rounded-xl group" transition:slide={{axis:'x'}}>
                            {#if isImage(url)}
                                <img src={url} class="w-full h-full object-cover rounded-xl" />
                            {:else if isVideo(url)}
                                <video src={url} class="w-full h-full object-cover rounded-xl" />
                            {:else}
                                <div class="bg-base-300h-full overflow-hidden p-4 rounded-xl">
                                    {url}
                                </div>
                            {/if}
                            <button
                                class="absolute top-2 right-2 p-2 hidden group-hover:block rounded-full bg-opacity-20 cursor-pointer hover:bg-black/50 hover:text-white transition-all duration-200"
                                on:click={() => {uploadedFiles = uploadedFiles.filter(u => u !== url)}}
                            >
                                <X class="w-6 h-6" />
                            </button>
                        </div>
                    {/each}
                </div>
            {/if}
        </div>
    </div>
</div>