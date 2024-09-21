<script lang="ts">
	import { goto, pushState } from '$app/navigation';
	import { ndk } from "$stores/ndk.js";
	import { NDKEvent, NDKEventId, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable } from "svelte/store";
    import currentUser from '$stores/currentUser';
    import sanitizeHtml from 'sanitize-html';
	import { onDestroy, onMount } from 'svelte';
	import HighlightMarks from './HighlightMarks.svelte';
	import { browser } from '$app/environment';
	import { layout } from '$stores/layout';
	import EmbeddedEventWrapper from '$components/Events/EmbeddedEventWrapper.svelte';
    import {Drawer} from 'vaul-svelte';
	import Highlight from '$components/Highlight.svelte';
    import * as Card from '$components/Card';
	import Zap from '$components/Footer/Buttons/Zap.svelte';
	import Comments from '$components/Footer/Buttons/Comments.svelte';
	import Share from '$components/Footer/Buttons/Share.svelte';
	import Bookmark from '$components/Footer/Buttons/Bookmark.svelte';

    export let event: NDKEvent | undefined = undefined;
    export let highlights: Readable<NDKEvent[]>;
    export let content: string = event?.content || '';

    const appliedHighlightIds = new Set<NDKEventId>();
    let highlightsToMark: NDKEvent[] = [];

    let isMobile = false;

    onMount(() => {
        isMobile = window.innerWidth < 768;
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

    $: for (const highlight of $highlights) {
        if (appliedHighlightIds.has(highlight.id)) continue;

        const highlightContent = highlight.content.trim();

        // discard low quality highlights
        if (highlightContent === '') continue;
        if (highlightContent.length < 5 && highlight.pubkey !== $currentUser?.pubkey) {
            appliedHighlightIds.add(highlight.id);
            continue;
        }

        // create regexp from highlight content (escape special characters)
        const regexp = new RegExp(highlightContent.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');

        content = content.replace(regexp, (match) => {
            appliedHighlightIds.add(highlight.id);
            highlightsToMark.push(highlight)
            highlightsToMark = highlightsToMark;
            return `<mark data-highlight-id="${highlight.id}">${match}</mark>`;
        })
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
</script>

{#if openHighlight}
    <Drawer.Root onClose={() => setTimeout(() => {openHighlight = undefined}, 300)} bind:open direction="right">
        <Drawer.Portal>
            <Drawer.Overlay class="fixed inset-0 bg-black/40" />
            <Drawer.Content
                class="
                    fixed flex flex-col p-6
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
    {#key content}
        <HighlightMarks
            {event}
            highlights={highlightsToMark}
        />
        
        <EventContent
            ndk={$ndk}
            {event}
            bind:content
            class="prose-lg leading-8 article-kind--{event.kind} {$$props.class??""}"
            on:click={handleClick}
            eventCardComponent={EmbeddedEventWrapper}
            sanitizeHtmlOptions={{
                allowedAttributes: {
                    'mark': [ 'data-highlight-id' ],
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