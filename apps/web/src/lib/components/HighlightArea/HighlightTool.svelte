<!--
    This is a tool that responds to selections such that we can show a popup hovering over a selection,
    providing tools for the user to interact with the content (quote, comment, zap, etc)
-->
<script lang="ts">
	import { onDestroy, onMount } from "svelte";
	import { activeSelection } from '$stores/highlight-tool';

    export let contentContainer: HTMLElement;

    function positionToolFromSelection() {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) { return; }
        const text = selection.toString().trim();
        if (!text || text.length < 5) {
            return;
        }
    }

    function updateSelection() {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) {
            $activeSelection = null;
            return;
        }
        const text = selection.toString().trim();
        if (!text || text.length < 5) {
            $activeSelection = null;
            return;
        }

        $activeSelection = selection;
    }

    function selectClickedElement(event: MouseEvent) {
        if ($activeSelection) return; // Prevent triggering if actively selecting

        const target = event.target as HTMLElement;
        const paragraph = target.closest('p'); // Find the closest paragraph element
        if (!paragraph) return; // Exit if no paragraph was clicked

        const selection = window.getSelection();
        const range = document.createRange();
        range.selectNode(paragraph);
        if (!selection) return;
        selection.removeAllRanges();
        selection.addRange(range);

        $activeSelection = selection;
    }

    onMount(() => {
        contentContainer.addEventListener("selectionchange", positionToolFromSelection, { passive: true });
        contentContainer.addEventListener("touchend", updateSelection, { passive: true });
        contentContainer.addEventListener("mouseup", updateSelection, { passive: true });

        // contentContainer.addEventListener("click", selectClickedElement);
    })

    onDestroy(() => {
        contentContainer.removeEventListener("selectionchange", positionToolFromSelection);
        contentContainer.removeEventListener("touchend", updateSelection);
        contentContainer.removeEventListener("mouseup", updateSelection);

        // contentContainer.removeEventListener("click", selectClickedElement);
    })
</script>
