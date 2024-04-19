<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import { relaySetForEvent } from "$utils/event";
	import { ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NDKTag, NostrEvent, getRootEventId, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { fade } from "svelte/transition";
	import Attachments from "./Attachments.svelte";

    export let extraTags: NDKTag[] = [];
    export let kind: NDKKind;
    export let event: NDKEvent = new NDKEvent($ndk, { kind, tags: extraTags } as NostrEvent);
    export let showReply: boolean | undefined = undefined;
    export let placeholder = "Reply...";
    export let hasFocus = false;
    export let autofocus = false;
    export let collapsed = true;

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

    $: if (hasFocus) {
        collapsed = false;
    } else {
        collapsed = content.length === 0;
    };
    $: collapsed = false;

    let uploadedFiles: string[] = [];
</script>

{#if hasFocus && content.length > 0}
    <div transition:fade class="absolute right-0 bottom-0 top-0 left-0 bg-black/40 z-30"></div>
{/if}

<div class="
    relative z-[40] w-full
    flex flex-col
    {collapsed ? "" : "max-sm:!fixed max-sm:bottom-0 max-sm:left-0 max-sm:right-0 max-sm:top-0 max-sm:!z-[50] max-sm:!bg-base-100/90 max-sm:backdrop-blur-[50px] max-sm:overflow-y-auto max-sm:h-[100dvh] max-sm:pt-10"}
" class:hidden={publishing}>
    {#key resetEditorAt}
        <ContentEditor
            bind:content
            toolbar={false}
            {placeholder}
            {autofocus}
            allowMarkdown={false}
            on:submit={publish}
            class="
                {collapsed ? "sm:min-h-[7rem]" : "sm:min-h-[10rem] flex-grow"}
            {$$props.class??""}"
        />

        <div class="px-4 mb-4" class:hidden={collapsed}>
            <Attachments buttonClass="btn btn-circle btn-ghost" bind:uploadedFiles />
        </div>
    {/key}
    <div class="h-14 pt-4"></div>
    <div class="absolute -z-1 left-0 flex flex-row gap-6 pt-2 sm:border-t border-base-300 w-full px-4 justify-end z-40 max-sm:flex-row-reverse bottom-4
        {collapsed ? "" : "max-sm:justify-between max-sm:top-0 "}
    ">
        <button class="
            button
            {collapsed ? "button px-6" : "max-sm:bg-accent2 max-sm:text-white px-10"}
        " on:click={publish} disabled={content.length === 0}>
            {#if publishing}
                Publishing...
            {:else}
                Reply
            {/if}
        </button>

        <button class="" on:click={() => { content = ""; resetEditorAt = new Date(); hasFocus = false; showReply = false} }>
            Cancel
        </button>
    </div>
</div>