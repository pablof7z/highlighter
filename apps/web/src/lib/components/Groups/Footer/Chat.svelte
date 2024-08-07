<script lang="ts">
	import Record from '$components/buttons/Record.svelte';
    import ChatInput from '$components/Chat/Input.svelte';
    import * as Footer from "$components/Footer";
	import { ndk } from '$stores/ndk';
    import { NDKSimpleGroup, NDKEvent, NDKTag, NDKKind } from "@nostr-dev-kit/ndk";
	import { Writable } from 'svelte/store';

    export let group: NDKSimpleGroup | undefined = undefined;
    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind = NDKKind.GroupChat;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean | undefined = undefined;
    export let replyTo: Writable<NDKEvent | undefined>;

        console.log('loaded with... group', group)
        if (group?.relaySet?.relays?.size > 0) {
        console.log('loaded with group', Array.from(group.relaySet.relays)[0].status)
    } else {
        console.log('loaded without group')
    }
    console.log("group", group?.relaySet);

    let collapsed = true;
    let recordingActive = false;
    let content = '';

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

<Footer.Shell
    bind:collapsed
    align="items-center"
>
    <div class="flex flex-row items-end w-full">
    <div class="w-full flex flex-col overflow-clip" class:hidden={recordingActive}>
        <ChatInput
            {group} {event} {tags} {kind} {placeholder} {showReplyingTo} bind:replyTo={$replyTo}
            class="w-full max-w-screen flex overflow-clip"
            bind:content
        />
    </div>
    {#if content.length === 0}
        <Record
            buttonProps={{
                variant: "invisible",
                class: "flex-none p-0 w-10 h-8",
            }}
            bind:active={recordingActive}
            on:uploaded={onUploaded}
        />
    {/if}
    </div>
</Footer.Shell>