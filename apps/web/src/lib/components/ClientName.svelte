<script lang="ts">
	import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    export let label = "via [client]";

    const clientTag = event.tags.find(tag => tag[0] === "client");
    let clientName: string | undefined;

    if (clientTag) {
        clientName = clientTag[1];

        // some events are broken and have the client nip-89 on the first tag, ignore those
        if (clientName.match(/31990:/)) clientName = undefined;
    }

    if (clientName)
        label = label.replace("[client]", clientName);
</script>

{#if clientName}
    <div class={
        $$props.class ?? "text-xs opacity-60"
    }>{label}</div>
{/if}