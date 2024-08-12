<script lang="ts">
	import { NDKEvent } from "@nostr-dev-kit/ndk";
	import { ComponentType } from "svelte";

    export let event: NDKEvent;

    let component: ComponentType;

    switch (event.kind) {
        case 6300: import("./NostrDiscovery.svelte").then((m) => component = m.default); break;
    }
</script>

{#if component}
    <svelte:component this={component} {event} />
{:else}
    <p>Unsupported event kind: {event.kind}</p>
{/if}