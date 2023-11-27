<script lang="ts">
	import { publishToTiers } from "$actions/publishToTiers";
	import SelectTier from "$components/Forms/SelectTier.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { Textarea, ndk, newToasterMessage, UploadButton } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { Image, X } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    const allTiers = getUserSupportPlansStore();

    let tiers: Record<string, boolean> = { "Free": false };
    let content: string;

    $: for (const tier of $allTiers) {
        if (tiers[tier.title] === undefined) {
            tiers[tier.title] = false;
        }
    }

    let publishing = false;

    async function publish() {
        publishing = true;

        const note = new NDKEvent($ndk, {
            kind: NDKKind.GroupNote,
            content,
        } as NostrEvent);

        // append all uploaded files to the note's content separated by new lines
        if (uploadedFiles.length > 0) {
            note.content += "\n\n" + uploadedFiles.join("\n");
        }

        try {
            publishToTiers(note, tiers);
        } catch (e: any) {
            console.error(e);
            newToasterMessage("Failed to publish note: "+e?.message, "error");
        } finally {
            publishing = false;
        }
    }

    let uploadedFiles: string[] = [];

    function uploaded(e: CustomEvent<string>) {
        const url = e.detail;
        uploadedFiles.push(url);
        uploadedFiles = uploadedFiles;
    }

    function isImage(url: string) {
        return url.match(/\.(jpeg|jpg|gif|png|webp|tiff|psd|raw|bmp|heif)$/i);
    }

    function isVideo(url: string) {
        return url.match(/\.(mp4|webm|ogg|mov|avi|wmv|flv|mkv)$/i);
    }
</script>

<div class="flex flex-col gap-10">
    <PageTitle title="New Note">
        <div class="flex flex-row gap-2">
            <button on:click={publish} class="button px-10" disabled={publishing}>
                {#if publishing}
                    <div class="loading loading-sm"></div>
                {:else}
                    Publish
                {/if}
            </button>
        </div>
    </PageTitle>

    <Textarea
        bind:value={content}
        autofocus={true}
        class="w-full rounded-xl min-h-[216px] font-normal text-base leading-normal"
    />

    <div class="flex flex-col gap-4">
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

    <SelectTier bind:tiers />
</div>

<style lang="postcss">
    .attachments img {
        /* Make the object cover be positioned at the top-left */
        @apply object-left-top;
    }
</style>