<script lang="ts">
	import ContentEditor from "$components/Forms/ContentEditor.svelte";
	import GlassyInput from "$components/Forms/GlassyInput.svelte";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { Textarea, ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NDKRelay, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { PaperPlaneTilt } from "phosphor-svelte";

    export let tags: NDKTag[] = [];

    const relaySet = getDefaultRelaySet();

    let content = '';
    let publishing = false;

    let resetAt = new Date();

    async function submit() {
        publishing = true;
        const e = new NDKEvent($ndk, {
            content,
            kind: NDKKind.GroupChat,
            tags: [
                ...tags
            ]
        } as NostrEvent)
        let publishedEvents: Set<NDKRelay>;
        try {
            publishedEvents = await e.publish(relaySet);
            if (publishedEvents.size > 0) {
                content = '';
                resetAt = new Date();
            } else {
                newToasterMessage("Failed to publish message");
            }

        } catch (e: any) {
            newToasterMessage("Failed to publish message: " + e.relayErrors);
        }

        publishing = false;
    }

    async function onkeydown({detail: event}: CustomEvent<KeyboardEvent>) {
        if (event.key === 'Enter' && !event.shiftKey && !publishing && content.trim().length > 0) {
            event.preventDefault();
            
        }
    }
</script>

<div class="flex flex-row justify-stretch !backdrop-blur-[50px] border-t border-white/20 px-4">
    {#key resetAt}
    <ContentEditor
        color="black"
        markdown={false}
        toolbar={false}
        autofocus={true}
        bind:content
        rows={1}
        enterSubmits={true}
        class="!min-h-none w-full grow rounded-box p-4 overflow-hidden !bg-transparent !border-0"
        on:keydown={onkeydown}
        on:submit={submit}
        placeholder="Type a message"
        captureTyping={true}
    />
    {/key}

    <div class="z-50 right-2 flex justify-end items-center bottom-0">
        {#if publishing}
            <div class="loading loading-sm text-accent2 loading-bars"></div>
        {:else}
            <button class="button rounded-full w-10 h-10 p-0.5 opacity-80">
                <PaperPlaneTilt class="text-black" />
            </button>
        {/if}
    </div>
</div>
