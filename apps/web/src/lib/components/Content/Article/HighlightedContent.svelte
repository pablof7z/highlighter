<script lang="ts">
	import { goto, pushState } from '$app/navigation';
	import { ndk } from "$stores/ndk.js";
    import type { Token as MarkedToken } from 'marked';
	import { Hexpubkey, NDKEvent, type NDKEventId, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { derived, Readable, writable } from "svelte/store";
    import currentUser from '$stores/currentUser';
    import sanitizeHtml from 'sanitize-html';
	import { onDestroy, onMount } from 'svelte';
	import HighlightMarks from './HighlightMarks.svelte';
	import { browser } from '$app/environment';
	import { layout } from '$stores/layout';
	import EmbeddedEventWrapper from '$components/Events/EmbeddedEventWrapper.svelte';
    import {Drawer} from 'vaul-svelte';
	import Highlight from '$components/Highlight.svelte';
	import Mention from '$components/Embeds/Mention.svelte';
	import EmbeddedHighlight from './EmbeddedHighlight.svelte';
	import { PushPin, CaretDown } from 'phosphor-svelte';
	import { pluralize } from '$utils';
	import ReplyAvatars from '$components/Feed/ReplyAvatars.svelte';
	import Hashtag from '$components/Embeds/Hashtag.svelte';
	import { showHighlightsIndicator } from '$stores/settings';

    export let event: NDKEvent | undefined = undefined;
    export let highlights: Readable<NDKEvent[]>;
    export let content: string = event?.content || '';

    const originalContent = content;

    /**
     * This store tracks the highlight Ids that have been marked in the content
     */
     type Range = {
        start: number;
        end: number;
        highlight: NDKHighlight;
    }
    const highlightedRanges = writable<Map<NDKEventId, Range>>(new Map());

    /**
     * This store tracks the highlights that have not been marked in the content
     */
    const highlightsToMark = derived([highlights, highlightedRanges], ([$highlights, $highlightedRanges]) => {
        return $highlights.filter(h => !$highlightedRanges.has(h.id));
    });
    
    let isMobile = false;

    export function resetView() {
        content = originalContent;
        highlightedRanges.set(new Map());

        countHighlightsOutsideViewport();
    }

    let highlightsOutsideViewport = 0;
    let highlightsOutsideViewportPubkeys = new Set<Hexpubkey>();

    function countHighlightsOutsideViewport() {
        const highlightElements = document.querySelectorAll('mark[data-highlight-id]');
        const viewportHeight = window.innerHeight;
        highlightsOutsideViewportPubkeys.clear();
        highlightsOutsideViewport = Array.from(highlightElements).filter(el => {
            const rect = el.getBoundingClientRect();
            return rect.top > viewportHeight;
        }).map(el => {
            const highlightId = el.getAttribute('data-highlight-id');
            if (highlightId) {
                const highlight = $highlights.find(h => h.id === highlightId);
                if (highlight) {
                    highlightsOutsideViewportPubkeys.add(highlight.pubkey);
                }
            }
        }).length;
    }

    onMount(() => {
        isMobile = window.innerWidth < 768;
        if (browser) {
            window.addEventListener('scroll', countHighlightsOutsideViewport);
            window.addEventListener('resize', countHighlightsOutsideViewport);
            countHighlightsOutsideViewport();
        }
    });

    onDestroy(() => {
        if (browser) {
            window.removeEventListener('scroll', countHighlightsOutsideViewport);
            window.removeEventListener('resize', countHighlightsOutsideViewport);
        }
    });

    let openHighlight: NDKHighlight | undefined;

    function onClickOpenSidebar(event: MouseEvent) {
        const target = (event.target as HTMLElement).closest('mark');
        if (target?.tagName !== 'MARK') return;
        const highlightId = target.getAttribute('data-highlight-id');
        if (highlightId) {
            const highlight = $highlights.find(h => h.id === highlightId);
            if (highlight) {
                openHighlight = NDKHighlight.from(highlight);
                open = true;
            }
        }
    }

    // add an event listener to click events on <mark> elements
    if (browser) document.addEventListener('click', onClickOpenSidebar);

    onDestroy(() => {
        if (browser) document.removeEventListener('click', onClickOpenSidebar);
    });

    function createHighlightRegexp(highlight: NDKEvent) {
        const highlightContent = highlight.content.trim();
        // discard low quality highlights
        if (highlightContent.length < 10) return;

        const words = highlightContent.split(/\W+/).map(word => {
            return word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // escape special characters in the word
        });

        let regexpTemplate = words.map(word => word).join('.*?');
        // add matching of symbols at the beginning and end of the regexp but not of spaces or punctuation  
        regexpTemplate = `[^\\w\\s\\]]*${regexpTemplate}[^\\w\\s\\[]*`;
        return new RegExp(regexpTemplate);
    }

    let perf = 0;

    function annotateContentForMarkdown() {
        const start = performance.now();
        // go through the content and find the highlights
        for (const highlight of $highlightsToMark) {
            const regexp = createHighlightRegexp(highlight);
            if (!regexp) continue;

            // find the first match
            const firstMatch = regexp.exec(content);
            if (!firstMatch) continue;  

            $highlightedRanges.set(highlight.id, {
                start: firstMatch.index,
                end: firstMatch.index + firstMatch[0].length,
                highlight: NDKHighlight.from(highlight)
            });
        }

        perf += performance.now() - start;
        console.log('perf', perf, $highlightsToMark.length);

        // console.log("Highlighted ranges", highlightedRanges);
    }

    const markedHighlightIds = new Set<NDKEventId>();

    function annotateContentForHTML() {
        for (const highlight of $highlightsToMark) {
            const regexp = createHighlightRegexp(highlight);
            if (!regexp) continue;

            content = content.replace(regexp, (match) => {
                $highlightedRanges.set(highlight.id, {
                    start: content.indexOf(match),
                    end: content.indexOf(match) + match.length,
                    highlight: NDKHighlight.from(highlight)
                });
                return `<mark data-highlight-id="${highlight.id}">${match}</mark>`;
            });
        }
    }

    let open = true;

    $: if ($highlightsToMark.length > 0) {
        if (event) annotateContentForMarkdown();
        else annotateContentForHTML();
        countHighlightsOutsideViewport();
    }

    function scrollToFirstHighlight() {
        const highlightElements = document.querySelectorAll('mark[data-highlight-id]');
        const viewportHeight = window.innerHeight;

        for (const el of highlightElements) {
            const rect = el.getBoundingClientRect();
            if (rect.top > viewportHeight) {
                el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                break;
            }
        }
    }
</script>

{#if openHighlight}
    <Drawer.Root onClose={() => setTimeout(() => {openHighlight = undefined}, 300)} bind:open direction="right">
        <Drawer.Portal>
            <Drawer.Overlay class="fixed inset-0 bg-black/40" />
            <Drawer.Content
                class="
                    fixed flex p-6
                    bottom-0 right-0 top-0 w-[50%] flex-row rounded-l-[10px]
                    bg-background z-50
                    translate-x-1/2
                "
            >
                <div class="shrink">
                    <Highlight
                        highlight={openHighlight}
                        skipArticle
                    />
                </div>
            </Drawer.Content>
        </Drawer.Portal>
    </Drawer.Root>
{/if}

{#if event}
    {#key $highlights.length}
        <EventContent
            ndk={$ndk}
            {event}
            {content}
            class="prose-lg leading-8 article-kind--{event.kind} {$$props.class??""}"
            eventCardComponent={EmbeddedEventWrapper}
            sanitizeHtmlOptions={{
                allowedAttributes: {
                    'del': {},
                    'mark': [ 'data-highlight-id' ],
                    "img": ["src", "alt", "title"],
                    ...sanitizeHtml.defaults.allowedAttributes
                }
            }}
        />
    {/key}
{:else}
    <div class="article">
        {@html content}
    </div>
{/if}

{#if highlightsOutsideViewport > 0}
    <div
        class="
            flex flex-row group highlight-indicator-container rounded-full overflow-hidden items-center
            transition-all duration-300 hover:opacity-100
        "
        class:opacity-20={!$showHighlightsIndicator}
    >
        <div class="w-6 group-hover:bg-secondary group-hover:text-accent-foreground px-1">
            <button on:click={(e) => {$showHighlightsIndicator = !$showHighlightsIndicator; e.stopPropagation();}} class="opacity-0 group-hover:opacity-100 transition-all duration-300">
                <PushPin size={16} class="inline" weight="bold" />
            </button>
        </div>
        <button
            class="highlight-indicator"
            on:click={scrollToFirstHighlight}
        >
            {highlightsOutsideViewport}
            {pluralize(highlightsOutsideViewport, 'highlight')}

            {#key highlightsOutsideViewport}
                <ReplyAvatars users={Array.from(highlightsOutsideViewportPubkeys)} size="xs" />
            {/key}
            
            <CaretDown size={16} class="inline" weight="bold" />
        </button>
    </div>
{/if}

<style>
    .highlight-indicator-container {
        @apply fixed bottom-16 left-1/2 transform -translate-x-1/2;
    }

    .highlight-indicator {
        @apply transform bg-foreground text-xs text-background px-3 py-1.5 rounded-full z-50 flex items-center gap-1;
    }
</style>

