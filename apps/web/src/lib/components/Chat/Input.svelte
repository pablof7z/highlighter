<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import Name from "$components/User/Name.svelte";
	import { ndk } from "$stores/ndk";
	import { relaySetForEvent } from "$utils/event";
	import { NDKEvent, NDKKind, NDKRelay, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { PaperPlaneTilt } from "phosphor-svelte";

    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind = NDKKind.GroupChat;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean = false;

    const relaySet = event ? relaySetForEvent(event) : undefined;

    let content = '';
    let publishing = false;

    let resetAt = new Date();

    async function submit() {
        publishing = true;
        const e = new NDKEvent($ndk, {
            content,
            kind,
            tags: [
                ...tags
            ]
        } as NostrEvent)

        e.publish(relaySet);
        content = '';
        resetAt = new Date();

        publishing = false;
    }

    async function onkeydown({detail: event}: CustomEvent<KeyboardEvent>) {
        if (event.key === 'Enter' && !event.shiftKey && !publishing && content.trim().length > 0) {
            event.preventDefault();
            
        }
    }
</script>

<div class="flex flex-row justify-stretch !backdrop-blur-[50px] border-__t border-white/20 px-4">
    {#key resetAt}
        <div class="flex flex-col w-full">
            {#if showReplyingTo && event}
                {#key event?.pubkey}
                    <span class="text-xs text-accent">Replying to <Name pubkey={event.pubkey} /></span>
                {/key}
            {/if}
            <ContentEditor
                color="black"
                markdown={false}
                toolbar={false}
                autofocus={true}
                bind:content
                rows={1}
                enterSubmits={true}
                class="!min-h-none w-full grow rounded p-4 overflow-hidden !bg-transparent !border-0"
                on:keydown={onkeydown}
                on:submit={submit}
                {placeholder}
                captureTyping={true}
            />
        </div>
    {/key}

    <div class="z-50 right-2 flex justify-end items-center bottom-0">
        {#if publishing}
            <div class="loading loading-sm text-accent loading-bars"></div>
        {:else}
            <button class="button rounded-full w-10 h-10 p-0.5 opacity-80">
                <PaperPlaneTilt class="text-black" />
            </button>
        {/if}
    </div>
</div>
