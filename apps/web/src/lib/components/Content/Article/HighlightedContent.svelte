<script lang="ts">
	import { goto, pushState } from '$app/navigation';
	import { ndk } from "$stores/ndk.js";
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
	import { CaretDown } from 'phosphor-svelte';
	import { pluralize } from '$utils';
	import ReplyAvatars from '$components/Feed/ReplyAvatars.svelte';

    export let event: NDKEvent | undefined = undefined;
    export let highlights: Readable<NDKEvent[]>;
    export let content: string = event?.content || '';

    const originalContent = content;

    /**
     * This store tracks the highlight Ids that have been marked in the content
     */
    const processedHighlightIds = writable<Set<NDKEventId>>(new Set());

    /**
     * This store tracks the highlights that have not been marked in the content
     */
    const highlightsToMark = derived([highlights, processedHighlightIds], ([$highlights, $processedHighlightIds]) => {
        return $highlights.filter(h => !$processedHighlightIds.has(h.id));
    });
    
    let isMobile = false;

    export function resetView() {
        content = originalContent;
        $processedHighlightIds.clear();

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


    function annotateContentForMarkdown() {
        for (const highlight of $highlightsToMark) {
            const regexp = createHighlightRegexp(highlight);
            console.log("Regexp", regexp);
            if (!regexp) continue;

            content = content.replace(regexp, (match) => {
                $processedHighlightIds.add(highlight.id);
                return `[mark ${highlight.id}]${match}[/mark ${highlight.id}]`;
            })
        }

        console.log("Annotated content for markdown", content);
    }

    function annotateContentForHTML() {
        for (const highlight of $highlightsToMark) {
            const regexp = createHighlightRegexp(highlight);
            if (!regexp) continue;

            content = content.replace(regexp, (match) => {
                $processedHighlightIds.add(highlight.id);
                return `<mark data-highlight-id="${highlight.id}">${match}</mark>`;
            })
        }
    }

    function handleClick(event: CustomEvent<{type: string}>) {
        switch (event.detail.type) {
            case "profile": {
                const { npub, nip05 } = event.detail;

                if (nip05) goto(`/${nip05}`)
                else goto(`/${npub}`)
                break;
            }
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

    // let inHighlights: [NDKEventId, number][] = [];
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
            bind:content
            class="prose-lg leading-8 article-kind--{event.kind} {$$props.class??""}"
            on:click={handleClick}
            eventCardComponent={EmbeddedEventWrapper}
            sanitizeHtmlOptions={{
                allowedAttributes: {
                    'del': {},
                    'mark': [ 'data-highlight-id' ],
                    "img": ["src", "alt", "title"],
                    ...sanitizeHtml.defaults.allowedAttributes
                }
            }}
            markedExtensions={[{
                extensions: [{
                    name: 'highlight',
                    level: 'inline',
                    start(src) {
                        return src.match(/^\[mark/)?.index;
                    },
                    tokenizer(src) {
                        const markIndex = src.indexOf('[mark');
                        if (markIndex === -1) return;
                        const id = src.slice(markIndex + 6, src.indexOf(']', markIndex));

                        // start of the text
                        const start = src.indexOf(']', markIndex) + 1;

                        // end of the text
                        const end = src.indexOf('[/mark ' + id + ']', start);
                        const endOfMark = src.indexOf(']', end);
                        
                        if (start === -1 || end === -1) return;

                        // trim out the [mark] and [/mark]
                        const text = src.slice(start, end);

                        const highlight = $highlights.find(h => h.id === id);
                        if (!highlight) return;

                        const token = {
                            type: 'paragraph',
                            raw: src,
                            tokens: [],
                        }

                        // // get the text before the highlight
                        if (markIndex > 0) {
                            const textBefore = src.slice(0, markIndex);
                            const t = {
                                type: 'text',
                                raw: textBefore,
                                text: textBefore,
                                tokens: [],
                            };

                            this.lexer.inlineTokens(textBefore, t.tokens);
                            token.tokens.push(t);
                        }

                        console.log("HL tokenizer", {markIndex, end, endOfMark, start, text, id, highlight, src})

                        const t = { 
                            type: 'highlight',
                            raw: src.slice(markIndex, endOfMark+1),
                            text: text,
                            highlightId: id,
                            pubkeys: [highlight.pubkey],
                            highlight,
                            tokens: [],
                        };

                        this.lexer.inlineTokens(text, t.tokens);
                        token.tokens.push(t);

                        // get the text after the highlight
                        const textAfter = src.slice(endOfMark + 1);
                        if (textAfter.length > 0) {
                            token.tokens.push({
                                type: 'text',
                                raw: textAfter,
                                text: textAfter,
                            });
                        }

                        return {
                            type: 'paragraph',
                            raw: src,
                            tokens: token.tokens,
                        };
                    },
                }]
            }]}
            renderers={{
                highlight: EmbeddedHighlight,
            }}
            components={{
                mention: Mention,
                event: EmbeddedEventWrapper,
            }}
        />
    {/key}
{:else}
    <div class="article">
        {@html content}
    </div>
{/if}

{#if highlightsOutsideViewport > 0}
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
{/if}

<style>
    .highlight-indicator {
        @apply fixed bottom-16 left-1/2 transform -translate-x-1/2 bg-foreground text-xs text-background px-3 py-1.5 rounded-full z-50 flex items-center gap-1;
    }
</style>

