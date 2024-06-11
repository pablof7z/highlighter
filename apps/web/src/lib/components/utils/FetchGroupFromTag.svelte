<script lang="ts">
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKTag } from "@nostr-dev-kit/ndk";

    export let tag: NDKTag;
    const [ label, groupId, relayUrl ] = tag;

    const relay = relayUrl ? $ndk.pool.getRelay(relayUrl) : undefined;
    let group: NDKEvent | null;

    $ndk.fetchEvent(groupId, { subId: 'fetch-group-from-tag'}, relay)
        .then((event) => { group = event; });
</script>

{#if group}
    <slot {group} />
{/if}