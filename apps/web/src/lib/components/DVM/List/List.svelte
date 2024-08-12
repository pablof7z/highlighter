<script lang="ts">
	import ScrollArea from "$components/ui/scroll-area/scroll-area.svelte";
    import { ndk } from "$stores/ndk";
	import { NDKKind } from "@nostr-dev-kit/ndk";

    export let kind: NDKKind;

    const dvms = $ndk.storeSubscribe([
        { kinds: [NDKKind.AppHandler], "#k": [kind.toString()] }
    ])
</script>

<ScrollArea orientation="vertical" class="flex flex-col gap-2 border rounded h-full">
    <div class="flex flex-col gap-2 divide-y divide-border h-full">
        {#each $dvms as dvm (dvm.id)}
            {#if dvm}
                <slot {dvm} />
            {/if}
        {/each}
    </div>
</ScrollArea>