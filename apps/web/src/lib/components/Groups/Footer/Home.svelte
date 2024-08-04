<script lang="ts">
    import * as Footer from "$components/Footer";
	import { ndk } from '$stores/ndk';
    import { NDKSimpleGroup, NDKEvent, NDKTag, NDKKind, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";

    import NewItem from "$components/Footer/Views/NewItem";
	import { Readable } from "svelte/store";

    export let group: NDKSimpleGroup | undefined = undefined;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind = NDKKind.GroupChat;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean = false;

    let open: (value?: string | false) => void;
    
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

    async function onPublish(content: string) {

    }
</script>

<Footer.Shell
    bind:open
    align="items-start"
    buttons={[
        { ...NewItem, props: { group, groupMetadata: $metadata } }
    ]}
>
</Footer.Shell>