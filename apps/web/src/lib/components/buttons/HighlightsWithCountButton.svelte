<script lang="ts">
	import { ndk } from "$stores/ndk.js";
    import currentUser from "$stores/currentUser.js";
	import { NDKSubscriptionCacheUsage, type NDKEvent, NDKKind } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import { ChatCircle } from 'phosphor-svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
	import { slide } from "svelte/transition";

    export let event: NDKEvent;
    export let urlPrefix: string | undefined = undefined;

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
        return r.pubkey === $currentUser?.pubkey;
    }

    $: highlightedByUser = !!$highlights.find(findUserComment);
</script>

{#if $highlights.length > 0}
    <div class="p-2">
        <svelte:element
            this={urlPrefix ? "a" : "button"}
            href="{urlPrefix??""}/highlights"
            class="flex flex-row items-center gap-2 {highlightedByUser ? 'text-foreground' : ''}"
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
        </svelte:element>
    </div>
{/if}