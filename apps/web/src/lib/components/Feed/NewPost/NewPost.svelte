<script lang="ts">
	import Device from 'svelte-device-info';
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import { relaySetForEvent } from "$utils/event";
	import { Avatar, ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NDKTag, NostrEvent, getRootEventId, isEventOriginalPost } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { fade } from "svelte/transition";
	import Attachments from "./Attachments.svelte";
	import { Feather, Timer } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import currentUser from "$stores/currentUser";

    export let extraTags: NDKTag[] = [];
    export let kind: NDKKind;
    export let event: NDKEvent = new NDKEvent($ndk, { kind } as NostrEvent);
    export let showReply: boolean | undefined = undefined;
    export let placeholder = "Reply...";
    export let hasFocus = false;
    export let autofocus = false;
    export let collapsed: boolean | undefined = undefined;
    export let skipAvatar = false;
    export let isCollapsed: boolean | undefined = undefined;
    export let mentionEvent: NDKEvent | undefined = undefined;

    if (collapsed === undefined) {
        isCollapsed = true;
    } else {
        isCollapsed = collapsed;
    }

    const dispatch = createEventDispatcher();

    export let publishing = false;
    let content = event.content;
    let resetEditorAt = new Date();

    function cancel() {
        content = "";
        resetEditorAt = new Date();
        hasFocus = false;
        isCollapsed = collapsed ?? true;
        showReply = false;
        dispatch("cancel");
    }

    async function publish() {
        publishing = true;

        try {
            for (const url of uploadedFiles) {
                content += `\n\n${url}`;
            }

            event.tags = extraTags;

            // if we are mentioning an event, add it to the content and tag it
            if (mentionEvent) {
                content += `\n\nnostr:${mentionEvent.encode()}`;
                event.tag(mentionEvent, "mention", false, "q");
                if (mentionEvent.kind !== NDKKind.Text) {
                    event.tags.push(["k", mentionEvent.kind!.toString()]);
                }
                event.tag(mentionEvent.author);
            }

            event.content = content;
            const relaySet = relaySetForEvent(event);
            event.id = "";
            hasFocus = false;
            await event.sign();
            await event.publish(relaySet);
            event = new NDKEvent($ndk, { kind, tags: extraTags } as NostrEvent);
            content = "";
            resetEditorAt = new Date();
            isCollapsed = collapsed ?? true;
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

    const isMobile = Device.isMobile;

    $: if (!isMobile) {
        if (hasFocus) {
            isCollapsed = collapsed ?? false;
        } else {
            isCollapsed = collapsed ?? content.length === 0;
        }
    }

    let uploadedFiles: string[] = [];
</script>

{#if !isMobile && hasFocus && content.length > 0}
    <div transition:fade class="absolute right-0 bottom-0 top-0 left-0 bg-black/40 z-30"></div>
{/if}

<div class="
    relative z-[40] w-full
    flex flex-col
    max-sm:h-[90dvh]
" class:hidden={publishing}>
    <div class="flex flex-row">
        {#if !skipAvatar}
            <Avatar user={$currentUser} size="small" class="ml-4 mt-4" />
        {/if}
        {#key resetEditorAt}
            <div class="relative flex-grow flex flex-col">
                <ContentEditor
                    bind:content
                    toolbar={false}
                    on:focus={() => {hasFocus = true; dispatch('focus')}}
                    on:blur={() => hasFocus = false}
                    {placeholder}
                    {autofocus}
                    allowMarkdown={false}
                    on:submit={publish}
                    class="{
                        $$props.editorClass ? $$props.editorClass : (
                            `text-white ${(
                                isCollapsed ? "sm:min-h-[7rem]" : "sm:min-h-[10rem] flex-grow"
                            )}`
                        )}
                    {$$props.class??""}"
                />

                <div class="px-4 mb-4" class:hidden={isCollapsed}>
                    <Attachments buttonClass="btn btn-circle btn-ghost" bind:uploadedFiles />
                </div>

                {#if $$slots.afterContent}
                    <div class="mt-2">
                        <slot name="afterContent" />
                    </div>
                {/if}
            </div>
        {/key}
    </div>
    <div class="max-sm:fixed -z-1 left-0 flex flex-row gap-6 py-4 sm:border-t border-base-300 w-full px-4 justify-end z-40 bottom-4 max-sm:h-16
        {isCollapsed ? "" : "max-sm:justify-between max-sm:top-6"}
    ">
        {#if $$slots.buttonsBar}
            <slot name="buttonsBar" />
        {/if}
        <!-- <button class="btn btn-circle btn-ghost">
            <Timer class="w-6 h-6" />
        </button> -->
        <button class="
            button
            {isCollapsed ? "button px-6" : "max-sm:bg-accent2 max-sm:text-white px-6"}
        " on:click={publish} disabled={content.length === 0}>
            {#if publishing}
                Publishing...
            {:else}
                Post
            {/if}
        </button>

        <button class="" on:click={cancel}>
            Cancel
        </button>
    </div>
</div>