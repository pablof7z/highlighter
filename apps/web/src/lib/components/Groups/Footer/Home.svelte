<script lang="ts">
    import * as Footer from "$components/Footer";
    import { NDKEvent, NDKTag, NDKKind, NDKSimpleGroupMetadata } from "@nostr-dev-kit/ndk";

    import NewItem from "$components/Footer/Views/NewItem";
	import { Readable } from "svelte/store";
	import { GroupData } from "..";

    export let group: Readable<GroupData> | undefined = undefined;

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