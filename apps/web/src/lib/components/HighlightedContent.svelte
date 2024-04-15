<script lang="ts">
	import { ndk } from "@kind0/ui-common";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable } from "svelte/store";

    export let event: NDKEvent | undefined = undefined;
    export let highlights: Readable<NDKEvent[]>;
    export let content: string = event?.content || '';

    const appliedHighlightIds = new Set<NDKEventId>();

    $: for (const highlight of $highlights) {
        if (appliedHighlightIds.has(highlight.id)) continue;

        const highlightContent = highlight.content.trim();
        // create regexp from highlight content (escape special characters)
        const regexp = new RegExp(highlightContent.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');

        content = content.replace(regexp, (match) => {
            appliedHighlightIds.add(highlight.id);
            return `<mark data-highlight-id="${highlight.id}">${match}</mark>`;
        })
    }
</script>

{#if event}
    {#key content}
        <EventContent ndk={$ndk} {event} bind:content class="prose !max-w-none leading-8" />
    {/key}
{:else}
    <div class="article">
        {@html content}
    </div>
{/if}
