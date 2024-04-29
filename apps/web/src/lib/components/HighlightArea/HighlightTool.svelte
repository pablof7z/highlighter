<!--
    This is a tool that responds to selections such that we can show a popup hovering over a selection,
    providing tools for the user to interact with the content (quote, comment, zap, etc)
-->
<script lang="ts">
	import ShareModal from './../../modals/ShareModal.svelte';
	import QuoteModal from '$modals/QuoteModal.svelte';
	import HighlightIcon from "$icons/HighlightIcon.svelte";
    import Highlight from '$components/DetailView/Highlight.svelte';
	import { ChatCircle, Quotes, Repeat, Share } from "phosphor-svelte";
	import { onDestroy, onMount } from "svelte";
    import { ReferenceElement, autoUpdate, computePosition, offset } from '@floating-ui/dom';
	import { openModal } from "svelte-modals";
	import { NDKHighlight, NDKKind, NDKTag } from '@nostr-dev-kit/ndk';
	import { ndk } from '@kind0/ui-common';
	import { getParagraph, getText } from '$utils/text';
	import { pushState } from '$app/navigation';
	import { detailView } from '$stores/layout';

    export let contentContainer: HTMLElement;
    export let tags: NDKTag[] = [];
    let container: HTMLElement;

    async function getActiveHighlight() {
        if (!activeHighlightId) return null;
        return await $ndk.fetchEvent(activeHighlightId);
    }

    async function createHighlightFromSelection() {
        const highlight = new NDKHighlight($ndk);
        highlight.kind = NDKKind.Highlight;
        highlight.content = getText();
        highlight.tags = [
            [ "context", getParagraph() ],
            ...tags
        ]

        if (highlight.content.length < 5) return null;

        await highlight.sign();

        return highlight;
    }

    async function getHighlight() {
        if (activeHighlightId) {
            const h = await $ndk.fetchEvent(activeHighlightId);
            if (!h) return;
            return NDKHighlight.from(h);
        } else {
            return await createHighlightFromSelection();
        }
    }

    async function share() {
        const highlight = await getActiveHighlight();
        if (!highlight) return;
        openModal(ShareModal, { event: highlight });
    }
    
    async function highlight() {
        const highlight = await createHighlightFromSelection();
        if (!highlight) return;
        await highlight.publish();
    }

    async function quote() {
        const highlight = await getHighlight();
        if (!highlight) return;
        openModal(QuoteModal, { event: highlight, tags, onPublish: () => {
            highlight.publish();
            pushState(`/e/${highlight.encode()}`, {
                detailView: 'highlight'
            });
        } });
    }

    async function comment() {
        const highlight = await getHighlight();
        if (!highlight) return;

        openHighlightInDetailedView(highlight, { showReply: true });
    }

    function openHighlightInDetailedView(highlight: NDKHighlight, props: any) {
        pushState(`/e/${highlight.encode()}`, {
            detailView: 'highlight'
        });
        $detailView = {
            component: Highlight,
            props: {
                showReply: true,
                highlight,
                ...(props || {})
            }
        }
    }

    let top = -100
    let left = 0;

    let cleanup: (() => void) | null = null;

    function hide() {
        if (cleanup) cleanup();
        cleanup = null;
        container.style.opacity = '0';
        container.style.zIndex = '-1';
    }

    function show() {
        container.style.opacity = '1';
        container.style.zIndex = '50';
    }

    function positionToolFromSelection() {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) { hide(); return; }
        const text = selection.toString().trim();
        if (!text || text.length < 5) { hide(); return; }

        // get range
        const range = selection.getRangeAt(0);
        if (!range) { hide(); return; }

        positionTool(range);

        activeHighlightId = null;
    }

    let activeOnHover = false;
    let timeoutToHide: any = null;

    function positionToolFromHighlightHover(event: MouseEvent) {
        // if the target is within the container, return
        let element: HTMLElement | null = event.target as HTMLElement;
        while (element) {
            if (element === container) {
                // If we are hovering the tool, don't hide it
                if (timeoutToHide) {
                    clearTimeout(timeoutToHide);
                    timeoutToHide = null;
                }
                return;
            }
            element = element.parentElement;
        }
        
        element = event.target as HTMLElement;
        if (element.tagName !== 'MARK') {
            // if we were hovering a highlight and we are not anymore, hide the tool
            // after a timeout (so the user has time to hover the tool)
            if (activeOnHover) {
                if (timeoutToHide) clearTimeout(timeoutToHide);
                timeoutToHide = setTimeout(() => {
                    if (container) hide();
                    activeOnHover = false;
                }, 1000);
            }
            return;
        }

        // make sure this element is contained in the content container
        let contained = false;
        let el: HTMLElement | null = element;
        while (el) {
            if (el === contentContainer) {
                contained = true;
                break;
            }
            el = el.parentElement;
        }

        if (!contained) return;

        activeOnHover = true;

        positionTool(element);

        // get data-highlight-id from el
        activeHighlightId = element.dataset.highlightId;
    }

    let activeHighlightId: string | null = null;

    function positionTool(el: ReferenceElement) {
        if (cleanup) cleanup();

        cleanup = autoUpdate(el, container, () => {
            computePosition(el, container, {
                middleware: [
                    offset(10)
                ]
            }).then(({x, y}) => {
                top = y;
                left = x;
            });
        });

        show();
    }

    function maybeHide(event: MouseEvent) {
        if (!container.contains(event.target as Node)) {
            hide();
        }
    }

    onMount(() => {
        document.addEventListener("selectionchange", positionToolFromSelection);
        document.addEventListener("touchend", positionToolFromSelection);
        document.addEventListener("mouseover", positionToolFromHighlightHover);
    })

    onDestroy(() => {
        document.removeEventListener("selectionchange", positionToolFromSelection);
        document.removeEventListener("touchend", positionToolFromSelection);
        document.removeEventListener("click", maybeHide);
    })
</script>

<div class="
    absolute top-0 left-0 whitespace-nowrap
    flex-nowrap
    divide-x divide-black
    overflow-clip
    z-50

    p-2 bg-base-300 rounded-box w-fit flex flex-row shadow-2xl gap-2
" style="
    top: {top}px;
    left: {left}px;
    opacity: {top === -100 ? 0 : 1};
" bind:this={container}>
    {#if !activeHighlightId}
        <button on:click={highlight}>
            <HighlightIcon class="w-6 h-6" />
            <span>Highlight</span>
        </button>
    {:else}
        <button on:click={share}>
            <Repeat class="w-6 h-6" weight="fill" />
            <span>Repost</span>
        </button>
    {/if}
    <button on:click={quote}>
        <Quotes class="w-6 h-6" weight="fill" />
        <span>Quote</span>
    </button>
    <button on:click={comment}>
        <ChatCircle class="w-6 h-6" weight="fill" />
        <span>Comment</span>
    </button>
</div>

<style lang="postcss">
    button {
        @apply bg-base-100 border border-base-100 hover:border-white/50 hover:bg-base-200 rounded-box p-4 flex flex-col items-center gap-2 w-24 h-24;
    }

    button span {
        @apply text-base-100-content text-opacity-80 group-hover:text-opacity-100 font-medium text-sm;
    }
</style>