<script lang="ts">
	import { slide } from 'svelte/transition';
	import { ndk } from "$stores/ndk.js";
	import type { NDKEvent } from "@nostr-dev-kit/ndk";
	import { Check } from "phosphor-svelte";
	import { onDestroy } from "svelte";
	import { creatorRelayPubkey } from '$utils/const';

    export let subscribeEvent: NDKEvent;
    let statusEvent: NDKEvent;

    const sub = $ndk.subscribe({
        kinds: [24001],
        authors: [creatorRelayPubkey],
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
                <Check class="text-green-500" weight="bold" />
            {:else if status === "processing"}
                <span class="loading loading-xs text-neutral-500"></span>
            {/if}
            <span>{text}</span>
        </div>
    {/each}
    </div>
{/if}
