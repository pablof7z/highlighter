<script lang="ts">
	import { isImage, isVideo } from "$utils/media";
	import { Input, Textarea, UploadButton } from "@kind0/ui-common";
	import type { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";
	import { Image, X } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    export let note: NDKEvent;
    export let uploadedFiles: string[] = [];
    export let skipUploadButton = false;

    export let title: string;

    $: {
        note.removeTag("title");
        note.tags.push(["title", title]);
    }

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

    let contentAreaElement: HTMLTextAreaElement;

    function onTitleKeyDown(e: KeyboardEvent) {
        if (e.key === "Enter") {
            e.preventDefault();
            // move focus to content
            if (contentAreaElement) contentAreaElement.focus();
        }
    }
</script>

<div class="">
    <div class="w-full sm:rounded-box max-sm:border-none !border-base-300">
        <Input
            bind:value={title}
            color="black"
            class="!bg-transparent !text-2xl border-none !p-0 rounded-lg focus:ring-0 text-white font-['InterDisplay'] placeholder:text-white/50 placeholder:font-normal mb-4 w-full"
            placeholder="What is this conversation about?"
            on:keydown={onTitleKeyDown}
            autofocus={true}
        />
        <Textarea
            bind:value={note.content}
            bind:element={contentAreaElement}
            class="w-full flex-grow font-normal border-none text-lg leading-normal !bg-transparent  text-neutral-400 min-h-[15rem] p-0"
            placeholder="Write your note here..."
        />

        <div class="flex flex-col gap-4 max-sm:px-4">
            {#if !skipUploadButton}
                <div class="flex flex-row items-center text-white gap-4">
                    <UploadButton class="button w-10 h-10 !rounded-full p-1" on:uploaded={uploaded}>
                        <Image class="w-6 h-6" />
                    </UploadButton>
                    Attachments
                </div>
            {/if}

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