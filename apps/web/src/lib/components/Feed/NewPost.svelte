<script lang="ts">
	import { NDKEvent, NDKKind, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";
    import Input from "$components/Forms/Input.svelte";
	import Page1 from "$components/Editor/NoteEditorPage/Page1.svelte";
	import { UploadButton, ndk, newToasterMessage } from "@kind0/ui-common";
    import { Image, X } from "phosphor-svelte";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { page } from "$app/stores";
	import { goto } from "$app/navigation";
	import { getUserSubscriptionTiersStore } from "$stores/user-view";
	import LengthIndicator from "$components/LengthIndicator.svelte";

    export let creatorUser: NDKUser;

    export let opened = true;

    let note = new NDKEvent($ndk);
    note.kind = NDKKind.GroupNote;

    const tiers = getUserSubscriptionTiersStore();

    async function publish() {
        note.tags.push(["h", creatorUser.pubkey])

        for (const url of uploadedFiles) {
            note.content += `\n\n${url}`;
        }

        try {
            await note.publish(getDefaultRelaySet())
            const id = note.encode();
            note = new NDKEvent($ndk);
            note.kind = NDKKind.GroupNote;
            opened = false;

            const authorId = $page.params.id;

            goto(`/${authorId}/posts/${id}`);
        } catch (e: any) {

            newToasterMessage(e.relayErrors, "error");
        }
    }

    let uploadedFiles: string[] = [];

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

    let title: string;
</script>

{#if !opened}
    <button class="text-left w-full" on:click={() => opened = true}>
        <div class="p-4">
            <div class="">
                <div class="w-full sm:rounded-box max-sm:border-none !border-base-300">
                    <Input
                        bind:value={title}
                        color="black"
                        class="!bg-transparent !text-xl border-none !p-0 rounded-lg focus:ring-0 !text-white/50 font-['InterDisplay'] placeholder:text-white/50 placeholder:font-normal mb-4 w-full"
                        placeholder="Start a new post..."
                    />
                </div>
            </div>
        </div>

        <div class="flex flex-row items-center justify-end gap-4 pt-0 p-4">
            <div class="flex flex-row items-center justify-end gap-4">
                <button class="button px-6" on:click={publish} disabled={note.content.length < 5}>
                    Publish
                </button>
            </div>
        </div>
    </button>
{:else}
    <div class="">
        <div class="p-4 border-b border-white/10">
            <Page1 bind:note skipUploadButton={true} bind:uploadedFiles bind:title />
        </div>

        <div class="flex flex-row items-center justify-between gap-4 p-4">
            <div class="flex flex-row items-center text-white gap-4">
                <UploadButton class="button w-10 h-10 !rounded-full p-1" on:uploaded={uploaded}>
                    <Image class="w-6 h-6" />
                </UploadButton>
                Attachments
            </div>

            <div class="flex flex-row items-center justify-end gap-4">
                <LengthIndicator text={note.content} />

                <button on:click={() => opened = false}>
                    Cancel
                </button>
                <button class="button px-6" on:click={publish} disabled={note.content.length < 5}>
                    Publish
                </button>
            </div>
        </div>
    </div>
{/if}