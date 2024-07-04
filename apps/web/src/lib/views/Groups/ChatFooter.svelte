<script lang="ts">
	import Record from '$components/buttons/Record.svelte';
import ChatInput from '$components/Chat/Input.svelte';
    import FooterShell from "$components/PageElements/Mobile/FooterShell.svelte";
	import { Button } from '$components/ui/button';
	import { ndk } from '$stores/ndk';
    import { NDKSimpleGroup, NDKEvent, NDKTag, NDKKind } from "@nostr-dev-kit/ndk";
	import { Microphone } from 'phosphor-svelte';

    export let group: NDKSimpleGroup | undefined = undefined;
    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind = NDKKind.GroupChat;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean = false;

    let collapsed = true;
    let recordingActive = false;

    async function onUploaded(e: CustomEvent) {
        const { url, mediaEvent } = e.detail;
        console.log("uploaded", e.detail.url, e.detail.mediaEvent);

        const event = new NDKEvent($ndk);
        event.kind = kind;
        event.tags = tags;
        if (mediaEvent) event.tags = [ ...mediaEvent.tags, ...event.tags ]
        event.content = url;
        await event.sign();
        event.publish(group?.relaySet);
    }
</script>

<FooterShell
    bind:collapsed
    align="items-start"
>
        <Record
            buttonProps={{
                variant: "accent",
                class: "rounded-full flex-none w-9 h-9 p-0"
            }}
            bind:active={recordingActive}
            on:uploaded={onUploaded}
        >
        </Record>

        <div class="w-full" class:hidden={recordingActive}>
            <ChatInput
                {group} {event} {tags} {kind} {placeholder} {showReplyingTo}
                class="w-full"
            />
        </div>
</FooterShell>