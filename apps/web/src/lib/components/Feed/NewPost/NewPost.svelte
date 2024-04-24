<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import { relaySetForEvent } from "$utils/event";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NDKTag, NostrEvent, getRootEventId, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { fade } from "svelte/transition";
	import Attachments from "./Attachments.svelte";
	import { Feather, Timer } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";

    export let extraTags: NDKTag[] = [];
    export let kind: NDKKind;
    export let event: NDKEvent = new NDKEvent($ndk, { kind, tags: extraTags } as NostrEvent);
    export let showReply: boolean | undefined = undefined;
    export let placeholder = "Reply...";
    export let hasFocus = false;
    export let autofocus = false;
    export let collapsed = true;

    const dispatch = createEventDispatcher();

    let publishing = false;
    let content = event.content;
    let resetEditorAt = new Date();

    async function publish() {
        publishing = true;

        try {
            for (const url of uploadedFiles) {
                content += `\n\n${url}`;
            }

            event.content = content;
            const relaySet = relaySetForEvent(event);
            event.id = "";
            hasFocus = false;
            await event.publish(relaySet);
            event = new NDKEvent($ndk, { kind, tags: extraTags } as NostrEvent);
            content = "";
            resetEditorAt = new Date();
            collapsed = true;
            dispatch("publish");
        } catch (e) {
            console.error(e);
            newToasterMessage(e.relayErrors ?? e.message, "error");
        } finally {
            publishing = false;
        }
    }

    onMount(() => {
        // scroll into view
        const el = document.getElementById("reply");
        if (el) {
            el.scrollIntoView({ behavior: "smooth", block: "center" });
        }
    })

    const isMobile = window.innerWidth < 640;

    $: if (!isMobile) {
        if (hasFocus) {
            collapsed = false;
        } else {
            collapsed = content.length === 0;
        }
    }

    let uploadedFiles: string[] = [];
</script>

{#if !isMobile && hasFocus && content.length > 0}
    <div transition:fade class="absolute right-0 bottom-0 top-0 left-0 bg-black/40 z-30"></div>
{/if}

{#if collapsed}
    <button class="sm:hidden btn btn-lg p-3 btn-circle bg-accent2 text-white fixed z-[99999] bottom-2 right-2" on:click={() => collapsed = false}>
        <Feather class="w-full h-full" weight="fill" />
    </button>
{/if}

<div class="
    relative z-[40] w-full
    flex flex-col
    {collapsed ? "max-sm:hidden" : "max-sm:!fixed max-sm:bottom-0 max-sm:left-0 max-sm:right-0 max-sm:top-0 max-sm:!z-[50] max-sm:!bg-base-100/90 max-sm:backdrop-blur-[50px] max-sm:overflow-y-auto max-sm:h-[100dvh] max-sm:pt-16"}
" class:hidden={publishing}>
    {#key resetEditorAt}
        <ContentEditor
            bind:content
            toolbar={false}
            on:focus={() => hasFocus = true}
            on:blur={() => hasFocus = false}
            {placeholder}
            {autofocus}
            allowMarkdown={false}
            on:submit={publish}
            class="
                text-white
                {collapsed ? "sm:min-h-[7rem]" : "sm:min-h-[10rem] flex-grow"}
            {$$props.class??""}"
        />

        <div class="px-4 mb-4" class:hidden={collapsed}>
            <Attachments buttonClass="btn btn-circle btn-ghost" bind:uploadedFiles />
        </div>
    {/key}
    <div class="max-sm:fixed -z-1 left-0 flex flex-row gap-6 py-4 sm:border-t border-base-300 w-full px-4 justify-end z-40 max-sm:flex-row-reverse bottom-4 max-sm:h-16
        {collapsed ? "" : "max-sm:justify-between max-sm:top-0 "}
    ">
        <!-- <button class="btn btn-circle btn-ghost">
            <Timer class="w-6 h-6" />
        </button> -->
        <button class="
            button
            {collapsed ? "button px-6" : "max-sm:bg-accent2 max-sm:text-white px-6"}
        " on:click={publish} disabled={content.length === 0}>
            {#if publishing}
                Publishing...
            {:else}
                Post
            {/if}
        </button>

        <button class="" on:click={() => { content = ""; resetEditorAt = new Date(); hasFocus = false; collapsed = true; showReply = false} }>
            Cancel
        </button>
    </div>
</div>