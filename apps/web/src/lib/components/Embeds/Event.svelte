<svelte:options customElement="ndk-event-embed" />
<script lang="ts">
	import EmbeddedEventWrapper from '$components/Events/EmbeddedEventWrapper.svelte';
	import { ndk } from '$stores/ndk';

    export let id: string | undefined = undefined;
    export let nevent: string | undefined = undefined;
    export let naddr: string | undefined = undefined;

    id ??= nevent || naddr;
</script>

{#if id}
    <div class="w-full">
        <EmbeddedEventWrapper id={id} />
    </div>
{:else}
    No bech32
{/if}