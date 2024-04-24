<script lang="ts">
	import { NDKEvent, NDKKind, NDKTag, NostrEvent } from '@nostr-dev-kit/ndk';
	import LogoGradient from "$icons/LogoGradient.svelte";
	import { getParagraph, getText } from '$utils/text';
	import { onMount } from 'svelte';
	import HighlightIcon from '$icons/HighlightIcon.svelte';
	import { ndk } from '@kind0/ui-common';

    export let tags: NDKTag[] = [];

    let paragraphFloat: HTMLDivElement;
    let el: HTMLDivElement;

    let container: HTMLElement;

    onMount(() => {
        setupHighlightingHandler();
    })

    function setupHighlightingHandler() {
        container.addEventListener('click', function(event) {
            // if the target is not the container nor a descendant of the container
            if (!el?.contains(event.target as Node)) {
                if (el?.classList.contains('opacity-0')) return;
                el?.classList.add('opacity-0');
            }
        });

        container.addEventListener('selectionchange', function(event) {
            let selection = window.getSelection();
            if (selection && selection.toString().length > 0) {
                let range = selection.getRangeAt(0);
                let rect = range.getBoundingClientRect();

                // Create the floating element
                el.style.top = (rect.top + window.scrollY - 50) + 'px';
                el.style.left = (rect.right + window.scrollX) + 'px';
                // remove opacity-0 class
                setTimeout(() => {
                    el?.classList.remove('opacity-0');
                }, 10)
                // setTimeout(() => {
                //     el?.appendChild(floatElement);
                // }, 100)
            }
        });

        container.addEventListener('mouseup', function(event) {
            let selection = window.getSelection();
            if (selection && selection.toString().length > 0) {
                let range = selection.getRangeAt(0);
                let rect = range.getBoundingClientRect();

                // Create the floating element
                el.style.top = (rect.top + window.scrollY - 50) + 'px';
                el.style.left = (rect.right + window.scrollX) + 'px';
                // remove opacity-0 class
                setTimeout(() => {
                    el?.classList.remove('opacity-0');
                }, 10)
                // setTimeout(() => {
                //     el?.appendChild(floatElement);
                // }, 100)
            }
        });

        // add a hover listener that only acts on elements with class article
        container.addEventListener('mouseover', function(event) {
            if (!paragraphFloat || paragraphFloat === null) return;

            // if (event.target?.classList.contains('article')) {
                // add a listener to the element that will add the float element
                // event.target.addEventListener('mouseup', function(event) {
                const element = event.target as HTMLElement;
                const rect = element.getBoundingClientRect();
                const toolRect = paragraphFloat.getBoundingClientRect();

                if (toolRect.height > rect.height) return;

                // remove active-paragraph class from all paragraphs
                const activeParagraphs = document.querySelectorAll('.active-paragraph');
                activeParagraphs.forEach((activeParagraph) => {
                    activeParagraph.classList.remove('active-paragraph');
                })

                // Create the floating element
                paragraphFloat.style.top = (rect.top + window.scrollY) + 'px';
                paragraphFloat.style.left = (rect.left + window.scrollX - paragraphFloat.offsetWidth - 20) + 'px';
                element.classList.add('active-paragraph');
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
            const toolRect = paragraphFloat?.getBoundingClientRect();
            if (!toolRect) return;

            if (toolRect.height > rect.height) return;

            // Create the floating element
            paragraphFloat.style.top = (rect.top + window.scrollY) + 'px';
            paragraphFloat.style.left = (rect.left + window.scrollX - paragraphFloat.offsetWidth - 20) + 'px';
        })
    }

    async function createParagraphHighlight() {
        const activeParagraphs = document.querySelectorAll('.active-paragraph');

        if (activeParagraphs.length === 0) return;

        const content = activeParagraphs[0].textContent;
        if (!content) return;

        const paragraph = getParagraph();

        const event = new NDKEvent($ndk, {
            kind: NDKKind.Highlight,
            content,
            tags: [
                ["alt", 'This is a highlight created in https://highlighter.com'],
                ...tags
            ]
        } as NostrEvent);

        if (paragraph && paragraph !== '') event.tags.push(["context", paragraph]);

        await event.publish()
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
    max-sm:ml-10 max-sm:-mt-10
" style="top: -100px">
    <!-- <div class="sm:tooltip tooltip-left" data-tip="Zap!">
        <button class="
            transition-all duration-300
            max-sm:text-white
            text-neutral-800 hover:text-accent2
        " on:click={() => {}}>
            <Lightning class="max-sm:w-8 max-sm:h-8 w-6 h-6" weight="fill" />
        </button>
    </div> -->

    <div class="tooltip tooltip-left" data-tip="Highlight paragraph">
        <button class="
            transition-all duration-300
            max-sm:text-white
            text-neutral-800 hover:text-accent2
        " on:click={createParagraphHighlight}>
            <LogoGradient class="max-sm:w-8 max-sm:h-8 w-6 h-6" />
            <!-- <HighlightIcon class="max-sm:w-8 max-sm:h-8 w-6 h-6" /> -->
        </button>
    </div>
</div>

<div bind:this={el} class="float-element z-50 absolute opacity-0 transition-all duration-300 flex flex-col gap-1" style="top: -100px">
    <button class="
        button px-4 py-3
        transition-all duration-300
    " on:click={createHighlight}>
        <HighlightIcon class="w-6 h-6" />
        Highlight
    </button>
</div>

<article bind:this={container} class={$$props.class??""}>
    <slot />
</article>

<style lang="postcss">
    :global(.float-element) {
        box-shadow: 0 0 10px #000;
    }

    :global(.article pre) {
        @apply mb-4;
    }

    :global(.article p), :global(.article ul), :global(.article li), :global(.article h1), :global(.article h2), :global(.article blockquote) {
        @apply relative;
    }

    :global(.article p::before), :global(.article ul::before), :global(.article h1::before), :global(.article li::before), :global(.article blockquote::before) {
        @apply transition-opacity duration-300 ease-in;
        content: "";
        top: 0;
        left: -10px;
        height: 100%;
        position: absolute;
        @apply border-l-4 border-accent2;
        @apply opacity-0;
    }

    :global(.article .active-paragraph::before) {
        @apply opacity-100;
    }
</style>