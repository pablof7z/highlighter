<script lang="ts">
	import { ndk, user } from "@kind0/ui-common";
	import { NDKSubscriptionCacheUsage, type NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { ChatCircle } from 'phosphor-svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { slide } from "svelte/transition";

    export let event: NDKEvent;
    export let urlPrefix: string;

    const highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], ...event.filter() },
        {
            cacheUsage: NDKSubscriptionCacheUsage.PARALLEL,
            groupableDelay: 100,
            groupableDelayType: "at-least",
        }
    );

    onDestroy(() => {
        highlights.unref();
    });

    let highlightedByUser = false;

    function findUserComment(r: NDKEvent) {
        return r.pubkey === $user?.pubkey;
    }

    $: highlightedByUser = !!$highlights.find(findUserComment);
</script>

{#if $highlights.length > 0}
    <div class="tooltip line-clamp-1 overflow-clip" data-tip="View article highlights" transition:slide={{axis: 'y'}}>
        <a
            href="{urlPrefix}/highlights"
            class="flex flex-row items-center gap-2 {highlightedByUser ? 'text-white' : ''}"
        >
            <HighlightIcon
                class="w-6 h-6"
                weight="{highlightedByUser ? 'fill' : 'regular'}"
            />

            <span class="font-light opacity-60">
                {#if $highlights.length > 0}
                    {$highlights.length}
                {/if}
            </span>
        </a>
    </div>
{/if}