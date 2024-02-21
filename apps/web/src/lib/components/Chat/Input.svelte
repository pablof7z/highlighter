<script lang="ts">
	import GlassyInput from "$components/Forms/GlassyInput.svelte";
	import { getDefaultRelaySet } from "$utils/ndk";
	import { Textarea, ndk, newToasterMessage } from "@kind0/ui-common";
	import { NDKEvent, NDKKind, NDKRelay, type NDKTag, type NostrEvent } from "@nostr-dev-kit/ndk";
	import { PaperPlaneTilt } from "phosphor-svelte";

    export let tags: NDKTag[] = [];

    const relaySet = getDefaultRelaySet();

    let content = '';
    let publishing = false;

    async function onkeydown({detail: event}: CustomEvent<KeyboardEvent>) {
        if (event.key === 'Enter' && !event.shiftKey && !publishing && content.trim().length > 0) {
            event.preventDefault();
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
                } else {
                    newToasterMessage("Failed to publish message");
                }

            } catch (e: any) {
                newToasterMessage("Failed to publish message: " + e.relayErrors);
            }

            publishing = false;
        }
    }
</script>

<div class="w-full flex flex-row relative justify-stretch">
    <Textarea
        color="black"
        bind:value={content}
        rows={1}
        class="!min-h-none w-full grow rounded-box p-4 overflow-hidden"
        on:keydown={onkeydown}
        captureTyping={true}
    />

    <div class="absolute right-2 flex justify-end items-end bottom-2">
        {#if publishing}
            <div class="loading loading-sm text-accent2 loading-bars"></div>
        {:else}
            <button>
                <PaperPlaneTilt />
            </button>
        {/if}
    </div>
</div>
