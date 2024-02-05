<script lang="ts">
    import Checkbox from "$components/Forms/Checkbox.svelte";
    import ModalShell from "$components/ModalShell.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import GuideToPreviews from '$lib/drawer/help/guide-to-previews.svelte';
	import { Avatar, Name, Textarea, ndk, pageDrawerToggle, rightSidebar, user } from "@kind0/ui-common";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Check, Info } from "phosphor-svelte";
	import { Modals, closeModal } from "svelte-modals";
	import { slide } from "svelte/transition";

    export let note: NDKEvent;
    export let preview: NDKEvent;
    export let authorLink: string;

    $: preview.pubkey = $user?.pubkey;

    let content: string = preview.content || note.content;
    let includeLink = true;

    let previewContentReadLink: string;
    $: previewContentReadLink = `\n\n--------------------------\n\nRead more like this on my Highlighter page on ${authorLink}`;

    function save() {
        // preview.content = content;
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

    $: { preview.content = content; preview = preview; }
</script>

<ModalShell color="glassy" class="max-h-[80vh] overflow-y-auto">
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
            on:keyup={() => { preview.content = content; preview = preview; }}
            autofocus={true}
            class="w-full sm:rounded-xl max-sm:border-none flex-grow font-normal text-lg leading-normal !bg-white/5 !border-base-300 text-neutral-400 p-6"
            placeholder="Write your note here..."
        />

        <Checkbox
            bind:value={includeLink}
            class="input-background"
        >
            Add link to your creator page
            <div slot="description" class="text-xs text-opacity-50">
                Embeds a link to your Highlighter page for new readers to
                be able to subscribe.
            </div>
        </Checkbox>
    </div>

    {#if content.length > 1}
        <div class="w-full bg-base-200 p-4 rounded-box scale-90 flex flex-col gap-6">
            <div class="article">
                {#key content}
                    <EventContent ndk={$ndk} event={preview} content={content + (includeLink ? previewContentReadLink : "")} />
                {/key}
            </div>

            <UserProfile user={$user} let:fetching let:userProfile>
                <div class="flex flex-row gap-4 items-center">
                    <Avatar {userProfile} {fetching} size="small" />
                    <Name {userProfile} {fetching} class="text-white text-[15px] font-semibold" />
                </div>
            </UserProfile>
        </div>
    {/if}

    <div class="flex flex-row gap-10 items-center justify-end w-full">
        <button class="text-white text-base" on:click={closeModal}>
            Close
        </button>
        <button class="button text-base px-6 py-3" on:click={save}>
            <Check class="w-4 h-4 mr-2" />
            Save
        </button>
    </div>
</ModalShell>