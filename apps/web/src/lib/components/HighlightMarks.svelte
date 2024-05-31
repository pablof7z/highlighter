<script lang="ts">
    import { NDKEvent, NDKEventId, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
	import HighlightMarkGroup from './HighlightMarkGroup.svelte';

    export let highlights: NDKEvent[];

    type HighlightPosition = {
        mark: HTMLElement;
        highlights: NDKEvent[];
        element?: HTMLElement
    }
    
    type GroupPosition = number;
    
    let highlightPositions: Record<GroupPosition, HighlightPosition> = {};
    let markElements: Record<NDKEventId, HTMLElement> = {};

    // get the <mark>'s positions
    $: for (const highlight of highlights) {
        if (markElements[highlight.id]) continue;

        const el = document.querySelector('mark[data-highlight-id="' + highlight.id + '"]');
        if (el instanceof HTMLElement) markElements[highlight.id] = el;
    }

    onMount(() => {
        calculateElementGroups();
    })

    $: if (highlights) calculateElementGroups();

    // function that gets a position and calculates a group position
    // so that elements that have a y=10 and y=11 end up in the same group
    // and elements that have a y=20 and y=25 end up in the same group
    function calculateGroupPosition(top: number) {
        return Math.floor(top / 10);
    }

    function calculateElementGroups() {
        highlightPositions = {};
        
        for (const [highlightId, markElement] of Object.entries(markElements)) {
            const rect = markElement.getBoundingClientRect();
            if (!rect) continue;
            const groupPosition = calculateGroupPosition(rect.top);
            if (!highlightPositions[groupPosition]) {
                highlightPositions[groupPosition] = {
                    highlights: [highlights.find(h => h.id === highlightId)!],
                    mark: markElement
                }
            } else {
                highlightPositions[groupPosition].highlights.push(highlights.find(h => h.id === highlightId)!);
                highlightPositions[groupPosition].mark = markElement;
            }
        }

        highlightPositions = highlightPositions;
    }
</script>

{#each Object.entries(highlightPositions) as [group, {mark, highlights}] (group)}
    <HighlightMarkGroup {mark} {highlights} />
{/each}