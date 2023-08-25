<script lang="ts">
	import type { NDKAppHandlerEvent } from "@nostr-dev-kit/ndk";
	import DvmTile from "./DvmTile.svelte";
	import type { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";

    export let dvms: NDKEventStore<NDKAppHandlerEvent>;
    export let selectedDvms: NDKAppHandlerEvent[];

    let selections: Record<string, boolean> = {};

    $: selectedDvms = Object.entries(selections)
        .filter(([_, v]) => v)
        .map(([k, _]) => $dvms.find((dvm: NDKAppHandlerEvent) => dvm.id === k)!);
</script>

<h1 class="text-3xl border-b border-b-base-300 pb-4">Choose one or more DVMs</h1>

<div class="grid grid-flow-col gap-4">
    {#each $dvms as dvm (dvm.id)}
        <DvmTile dvm={dvm} bind:selected={selections[dvm.id]} />
    {/each}
</div>
