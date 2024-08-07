<!--
    This is a tool that responds to selections such that we can show a popup hovering over a selection,
    providing tools for the user to interact with the content (quote, comment, zap, etc)
-->
<script lang="ts">
	import { onDestroy, onMount } from "svelte";
	import { footerMainView } from '$stores/layout';
	import { activeSelection } from '$stores/highlight-tool';

    export let contentContainer: HTMLElement;

    function positionToolFromSelection() {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) { return; }
        const text = selection.toString().trim();
        if (!text || text.length < 5) { return; }

        $footerMainView = 'highlight-tool';

        activeHighlightId = null;
    }

    function updateSelection() {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) {
            $activeSelection = null;
            $footerMainView = false;
            return;
        }
        const text = selection.toString().trim();
        if (!text || text.length < 5) {
            $activeSelection = null;
            $footerMainView = false;
            return;
        }

        $activeSelection = selection;
        $footerMainView = 'highlight-tool';
    }

    let activeHighlightId: string | null = null;

    function selectClickedElement(event: MouseEvent) {
        // select the clicked element
        const target = event.target as HTMLElement;
        // create selection
        const selection = window.getSelection();
        const range = document.createRange();
        range.selectNode(target);
        if (!selection) return;
        selection.removeAllRanges();
        selection.addRange(range);
        // update the selection

        $activeSelection = selection;
        $footerMainView = 'highlight-tool';
    }

    onMount(() => {
        contentContainer.addEventListener("selectionchange", positionToolFromSelection, { passive: true });
        contentContainer.addEventListener("touchend", updateSelection, { passive: true });
        contentContainer.addEventListener("mouseup", updateSelection, { passive: true });
        // contentContainer.addEventListener("mouseover", positionToolFromHighlightHover);

        // find all the p tags in the contentContainer and add a click event listener to them
        // const pTags = contentContainer.querySelectorAll("p");
        // pTags.forEach(p => {
        //     p.addEventListener("click", selectClickedElement);
        // });
    })

    onDestroy(() => {
        contentContainer.removeEventListener("selectionchange", positionToolFromSelection);
        contentContainer.removeEventListener("touchend", updateSelection);
    })
</script>
