<script lang="ts">
	import Highlight from './Highlight.svelte';
	import { NDKEvent, NDKKind, NDKRelay, NDKRelaySet, NDKTag, NostrEvent, NDKHighlight } from '@nostr-dev-kit/ndk';
	import LogoGradient from "$icons/LogoGradient.svelte";
	import { getParagraph, getText } from '$utils/text';
	import { onMount } from 'svelte';
	import { ndk } from "$stores/ndk";
	import { detailView } from '$stores/layout';
	import { pushState } from '$app/navigation';
	import HighlightTool from './HighlightArea/HighlightTool.svelte';

    export let tags: NDKTag[] = [];

    let paragraphFloat: HTMLDivElement;

    let container: HTMLElement;

    onMount(() => {
        setupHighlightingHandler();
    })

    function setupHighlightingHandler() {
        function moveElementToWithinElement(floatingEl: HTMLElement, el: HTMLElement) {
            // remove the paragraphFloat element from its parent and insert it next to the element
            if (floatingEl.parentElement) {
                floatingEl.parentElement.removeChild(floatingEl);
            }

            // insert it as the last child of this paragraph
            el.appendChild(floatingEl);
        }

        // add a hover listener that only acts on elements with class article
        container.addEventListener('mouseover', function(event) {
            if (!paragraphFloat || paragraphFloat === null) return;

            // if (event.target?.classList.contains('article')) {
                // add a listener to the element that will add the float element
                // event.target.addEventListener('mouseup', function(event) {
                let element = event.target as HTMLElement;

                // if it already has active-parapgrah, or one of its parents has active-paragraph, return
                // if this is not a paragraph, find the parent paragraph
                while (element.tagName !== 'P' && element.tagName !== 'UL') {
                    element = element.parentElement as HTMLElement;
                    if (!element) return;
                    if (element.classList.contains('article')) break;
                }

                if (element.classList.contains('active-paragraph')) return;
                
                const rect = element.getBoundingClientRect();
                const toolRect = paragraphFloat.getBoundingClientRect();

                if (toolRect.height > rect.height) return;

                // remove active-paragraph class from all paragraphs
                const activeParagraphs = document.querySelectorAll('.active-paragraph');
                activeParagraphs.forEach((activeParagraph) => {
                    activeParagraph.classList.remove('active-paragraph');
                })

                // Create the floating element
                // paragraphFloat.style.top = (rect.top + window.scrollY) + 'px';
                // paragraphFloat.style.left = (rect.left + window.scrollX - paragraphFloat.offsetWidth - 20) + 'px';
                element.classList.add('active-paragraph');

                moveElementToWithinElement(paragraphFloat, element);
        })

        // create a listener that fires when the document scrolls, when the user scrolls move the active paragraph float
        // to the first visible paragraph
        document.addEventListener('scroll', function(event) {
            // find the first visible paragraph
            const paragraphs = document.querySelectorAll('.article p, .article ul');
            let firstVisibleParagraph: HTMLElement | null = null;

            for (let i = 0; i < paragraphs.length; i++) {
                const paragraph = paragraphs[i] as HTMLElement;
                if (!paragraph) continue;
                const rect = paragraph.getBoundingClientRect();
                if (rect.top > 120 && rect.top < 400) {
                    firstVisibleParagraph = paragraph;
                    break;
                }
            }

            if (!firstVisibleParagraph) return;
            if (!paragraphFloat) return;

            const activeParagraphs = document.querySelectorAll('.active-paragraph');

            // remove active-paragraph class from all paragraphs
            activeParagraphs.forEach((activeParagraph) => {
                activeParagraph.classList.remove('active-paragraph');
            })

            firstVisibleParagraph.classList.add('active-paragraph');

            const rect = firstVisibleParagraph.getBoundingClientRect();
            // const toolRect = paragraphFloat?.getBoundingClientRect();
            // if (!toolRect) return;

            // if (toolRect.height > rect.height) return;

            // remove the paragraphFloat element from its parent and insert it next to the element
            if (paragraphFloat.parentElement) {
                paragraphFloat.parentElement.removeChild(paragraphFloat);
            }

            // insert it as the last child of this paragraph
            firstVisibleParagraph.appendChild(paragraphFloat);

            // Create the floating element
            // paragraphFloat.style.top = (rect.top + window.scrollY) + 'px';
            // paragraphFloat.style.left = (rect.left + window.scrollX - paragraphFloat.offsetWidth - 20) + 'px';
        })
    }

    let highlightTags: NDKTag[] = [
        ["alt", 'This is a highlight created in https://highlighter.com'],
        ...tags
    ];

    async function createParagraphHighlight() {
        const activeParagraphs = document.querySelectorAll('.active-paragraph');

        if (activeParagraphs.length === 0) return;

        const content = activeParagraphs[0].textContent;
        if (!content) return;

        const paragraph = getParagraph();

        const event = new NDKEvent($ndk, {
            kind: NDKKind.Highlight,
            content,
            tags: highlightTags
        } as NostrEvent);

        if (paragraph && paragraph !== '') event.tags.push(["context", paragraph]);

        await event.publish()
        pushState(`/e/${event.encode()}`, {
            detailView: 'highlight'
        });
        $detailView = {
            component: Highlight,
            props: { highlight: NDKHighlight.from(event) }
        }
    }

    async function createHighlight() {
        const content = getText();

        if (!content) return;

        const event = new NDKEvent($ndk, {
            kind: NDKKind.Highlight,
            content,
            tags: [
                [ "context", getParagraph() ],
                ...tags
            ]
        } as NostrEvent);

        await event.publish();
    }
</script>

<div bind:this={paragraphFloat} class="
    float-element z-20 absolute transition-all duration-300 flex
    flex-row sm:flex-col gap-1
    -translate-x-10 left-0 top-0
    max-sm:ml-5 max-sm:-mt-5
">
    <!-- <div class="sm:tooltip tooltip-left" data-tip="Zap!">
        <button class="
            transition-all duration-300
            max-sm:text-foreground
            text-neutral-800 hover:text-accent
        " on:click={() => {}}>
            <Lightning class="max-sm:w-8 max-sm:h-8 w-6 h-6" weight="fill" />
        </button>
    </div> -->

    <div class="tooltip tooltip-left" data-tip="Highlight paragraph">
        <button class="
            transition-all duration-300
            max-sm:text-foreground
            text-neutral-800 hover:text-accent
        " on:click={createParagraphHighlight}>
            <LogoGradient class="max-sm:w-5 max-sm:h-5 w-6 h-6" />
            <!-- <HighlightIcon class="max-sm:w-8 max-sm:h-8 w-6 h-6" /> -->
        </button>
    </div>
</div>

{#if container}
    <HighlightTool contentContainer={container} tags={highlightTags} />
{/if}

<article bind:this={container} class={$$props.class??""}>
    <slot />
</article>


<style lang="postcss">
    :global(.article pre) {
        @apply mb-4;
    }

    :global(.article p), :global(.article ul), :global(.article li), :global(.article h1), :global(.article h2), :global(.article blockquote) {
        @apply relative;
    }

    :global(.active-paragraph) {
        @apply relative;
    }

    :global(.article p::before), :global(.article blockquote::before) {
        @apply transition-opacity duration-300 ease-in;
        content: "";
        top: 0;
        left: -15px;
        @apply pl-4;
        height: 100%;
        position: absolute;
        @apply border-l-4 border-accent;
        @apply opacity-0;
    }

    :global(.article .active-paragraph::before) {
        @apply opacity-100;
    }
</style>