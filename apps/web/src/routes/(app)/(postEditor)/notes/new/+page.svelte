<script lang="ts">
	import { publishToTiers } from "$actions/publishToTiers";
	import { goto } from "$app/navigation";
	import SelectTier from "$components/Forms/SelectTier.svelte";
	import PageTitle from "$components/Page/PageTitle.svelte";
	import { getUserSupportPlansStore } from "$stores/user-view";
	import { isImage, isVideo } from "$utils/media";
	import { Textarea, ndk, newToasterMessage, UploadButton } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { Image, X } from "phosphor-svelte";
	import { slide } from "svelte/transition";

    const allTiers = getUserSupportPlansStore();

    let tiers: Record<string, boolean> = { "Free": true };
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
            await publishToTiers(note, tiers);
            goto("/dashboard");
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
</script>

<div class="flex flex-col gap-10 mx-auto max-w-2xl flex-grow max-sm:h-[calc(100dvh-5rem)]">
    <PageTitle title="New Note" class="max-sm:hidden">
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
        class="w-full sm:rounded-xl max-sm:border-none flex-grow font-normal text-lg leading-normal !bg-transparent !border-base-300 focus:!border-base-300 text-neutral-400 p-6"
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

    <div class="max-sm:px-4">
        <SelectTier bind:tiers />
    </div>

    <button on:click={publish} class="button px-10 py-2.5 rounded-none sm:hidden" disabled={publishing}>
        {#if publishing}
            <div class="loading loading-sm"></div>
        {:else}
            Publish
        {/if}
    </button>
</div>

<style lang="postcss">
    .attachments img {
        /* Make the object cover be positioned at the top-left */
        @apply object-left-top;
    }
</style>