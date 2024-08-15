<script lang="ts">
	import { State } from '.';
	import BlossomUpload from "$components/buttons/BlossomUpload.svelte";
	import { isImage, isVideo } from "$utils/media";
	import { NDKTag } from "@nostr-dev-kit/ndk";
	import { Image, Timer, X } from "phosphor-svelte";
	import { Writable } from "svelte/store";
	import { slide } from "svelte/transition";

    export let state: Writable<State>;
    export let uploadedFiles: string[] = $state?.attachments ?? [];

    function uploaded(e: CustomEvent<{url: string, tags: NDKTag[]}>) {
        const {url, tags} = e.detail;
        if (url) {
            uploadedFiles.push(url);
            uploadedFiles = uploadedFiles;
            state.update(s => {
                s.attachments ??= [];
                s.attachments.push(url)
                return s;
            });
        } else {
            console.error("Failed to upload file");
        }
    }
    
    let fileInput: HTMLInputElement;

    $: if ($state?.forceFileUpload && fileInput) {
        $state.forceFileUpload = false;
        fileInput.click();
        console.log('sent click')
    }
</script>

{#if uploadedFiles.length > 0}
    <div class="grid grid-flow-col overflow-x-auto w-full items-start justify-start gap-8 attachments pb-6" transition:slide>
        {#each uploadedFiles as url}
            <div class="relative w-72 h-40 rounded-xl group" transition:slide={{axis:'x'}}>
                {#if isImage(url)}
                    <img src={url} class="w-full h-full object-cover rounded-xl" />
                {:else if isVideo(url)}
                    <video src={url} class="w-full h-full object-cover rounded-xl" />
                {:else}
                    <div class="bg-foreground/20h-full overflow-hidden p-4 rounded-xl">
                        {url}
                    </div>
                {/if}
                <button
                    class="absolute top-2 right-2 p-2 hidden group-hover:block rounded-full bg-opacity-20 cursor-pointer hover:bg-black/50 hover:text-foreground transition-all duration-200"
                    on:click={() => {uploadedFiles = uploadedFiles.filter(u => u !== url)}}
                >
                    <X class="w-6 h-6" />
                </button>
            </div>
        {/each}
    </div>
{/if}

<BlossomUpload
    class="flex-none p-1"
    on:uploaded={uploaded}
    bind:fileInput
/>