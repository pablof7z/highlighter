<script lang="ts">
	import ItemLink from "$components/Events/ItemLink.svelte";
import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";

    export let inputTag: NDKTag;

    const [_, value, type] = inputTag;
    let inputEvent: NDKEvent | null | undefined;

    if (type === "event") {
        $ndk.fetchEvent(value).then(e => inputEvent = e);
    }
</script>

{#if inputEvent}
    <ItemLink event={inputEvent} />
{/if}