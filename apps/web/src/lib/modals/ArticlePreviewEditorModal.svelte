<script lang="ts">
    import Checkbox from "$components/Forms/Checkbox.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import GuideToPreviews from '$lib/drawer/help/guide-to-previews.svelte';
	import { Avatar, Name, Textarea, ndk, pageDrawerToggle, rightSidebar, user } from "@kind0/ui-common";
	import type { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Check, Info } from "phosphor-svelte";
	import { closeModal } from "svelte-modals";

    export let article: NDKArticle;
    export let preview: NDKArticle;
    export let authorLink: string;

    $: preview.pubkey = $user?.pubkey;

    let content: string = preview.content || article.content;

    let previewContentReadLink: string;
    $: previewContentReadLink = `\n\n--------------------------\n\nRead more like this on my Faaans page on ${authorLink}`;

    function save() {
        preview.content = content;
        preview = preview;
        closeModal();
    }

    function openGuide() {
        if (!$pageDrawerToggle) {
            $pageDrawerToggle = true;
            $rightSidebar = {
                component: GuideToPreviews,
                props: {}
            }
        } else {
            $pageDrawerToggle = false;
        }
    }
</script>

<ModalShell color="black" class="max-w-3xl w-full max-h-[80vh] overflow-y-auto">
    <div class="flex flex-col gap-1 items-center w-full">
        <div class="font-semibold text-white text-3xl">Teaser Preview</div>
        <div class="text-neutral-500 font-light leading-loose text-center">
            This is how your teaser will look like to non-subscribers.
        </div>
        <div class="alert alert-neutral text-sm font-light">
            <Info class="w-4 h-4 text-info" />
            <span>How to write a good teaser?</span>
            <button class="btn btn-info btn-outline btn-xs" on:click={openGuide}>
                Read our guide
            </button>
        </div>
    </div>

    <div class="flex flex-col items-stretch gap-2 w-full">
        <Textarea
            bind:value={content}
            class="w-full !bg-transparent border border-neutral-800 rounded-xl resize-none min-h-[50vh] text-lg text-white overflow-y-hidden"
        />
    </div>

    <div class="flex flex-row gap-10 items-center justify-end w-full">
        <button class="text-white text-sm" on:click={closeModal}>
            Close
        </button>
        <button class="button text-sm px-6 py-3" on:click={save}>
            <Check class="w-4 h-4 mr-2" />
            Save
        </button>
    </div>
</ModalShell>