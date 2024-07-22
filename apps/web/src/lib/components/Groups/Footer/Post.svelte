<script lang="ts">
    import * as Footer from "$components/Footer";
	import { ndk } from '$stores/ndk';
    import { NDKSimpleGroup, NDKEvent, NDKTag, NDKKind } from "@nostr-dev-kit/ndk";

    export let group: NDKSimpleGroup | undefined = undefined;
    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean = false;

    let collapsed = true;

    async function onPublish(content: string) {
        const event = new NDKEvent($ndk);
        event.kind = NDKKind.GroupNote;
        event.content = content;
        if (group) event.tags.push(["h", group.groupId, ...group.relayUrls() ]);
        await event.sign();
        event.publish(group?.relaySet);
    }
</script>

<Footer.Shell
    bind:collapsed
    align="items-center"
    {onPublish}
    {placeholder}
>
</Footer.Shell>