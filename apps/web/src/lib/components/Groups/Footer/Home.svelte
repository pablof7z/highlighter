<script lang="ts">
    import * as Footer from "$components/Footer";
    import { NDKEvent, NDKTag, NDKKind, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";

    import NewItem from "$components/Footer/Views/NewItem";
	import { Readable } from "svelte/store";
	import { Group } from "..";

    export let group: Readable<Group> | undefined = undefined;
    export let metadata: Readable<NDKSimpleGroupMetadata | undefined>;
    export let event: NDKEvent;
    export let tags: NDKTag[] = [];
    export let kind: NDKKind = NDKKind.GroupChat;
    export let placeholder: string = "Type a message";
    export let showReplyingTo: boolean = false;

    let open: (value?: string | false) => void;
</script>

<Footer.Shell
    bind:open
    align="items-start"
    views={[
        { ...NewItem, props: { group } }
    ]}
>
</Footer.Shell>