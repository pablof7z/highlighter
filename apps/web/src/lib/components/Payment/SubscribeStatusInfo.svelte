<script lang="ts">
	import { slide } from 'svelte/transition';
	import { trustedPubkeys } from "$utils/login";
	import { ndk } from "@kind0/ui-common";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Check } from "phosphor-svelte";
	import { onDestroy } from "svelte";

    export let subscribeEvent: NDKEvent;
    let statusEvent: NDKEvent;

    const sub = $ndk.subscribe({
        kinds: [24001],
        authors: trustedPubkeys,
        ...subscribeEvent.filter()
    });
    sub.on("event", (e) => statusEvent = e);

    onDestroy(() => {
        sub.stop();
    });
</script>

{#if statusEvent}
    <div class="text-sm flex flex-col items-start gap-2 font-normal w-full">
    {#each statusEvent.getMatchingTags('status') as [_, text, status]}
        <div class="flex flex-row items-center gap-3" transition:slide>
            {#if status === "done"}
                <Check class="text-success" weight="bold" />
            {:else if status === "processing"}
                <span class="loading loading-xs text-neutral-500"></span>
            {/if}
            <span>{text}</span>
        </div>
    {/each}
    </div>
{/if}
