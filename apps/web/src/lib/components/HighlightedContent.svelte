<script lang="ts">
	import { goto, pushState } from '$app/navigation';
	import { ndk, pageDrawerToggle, rightSidebar } from "@kind0/ui-common";
	import { NDKEvent, NDKEventId } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { Readable } from "svelte/store";
    import currentUser from '$stores/currentUser';
	import { detailView } from '$stores/layout';
	import Highlight from './DetailView/Highlight.svelte';
    import sanitizeHtml from 'sanitize-html';
	import { onDestroy, onMount } from 'svelte';
	import HighlightMarks from './HighlightMarks.svelte';

    export let event: NDKEvent | undefined = undefined;
    export let highlights: Readable<NDKEvent[]>;
    export let content: string = event?.content || '';

    const appliedHighlightIds = new Set<NDKEventId>();
    let highlightsToMark: NDKEvent[] = [];

    let isMobile = false;

    onMount(() => {
        isMobile = window.innerWidth < 768;
    });

    function onClickOpenSidebar(event: MouseEvent) {
        const target = (event.target as HTMLElement).closest('mark');
        if (target?.tagName !== 'MARK') return;
        const highlightId = target.getAttribute('data-highlight-id');
        if (highlightId) {
            const highlight = $highlights.find(h => h.id === highlightId);
            if (highlight) {
                pushState(`/e/${highlight.encode()}`, {
                    detailView: 'highlight'
                });
                $detailView = {
                    component: Highlight,
                    props: { highlight }
                }
            }
        }
    }

    // add an event listener to click events on <mark> elements
    document.addEventListener('click', onClickOpenSidebar);

    onDestroy(() => {
        document.removeEventListener('click', onClickOpenSidebar);
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
</script>

{#if event}
    {#key content}
        {#if !isMobile}
            <HighlightMarks
                {event}
                highlights={highlightsToMark}
            />
        {/if}
        
        <EventContent
            ndk={$ndk}
            {event}
            bind:content
            class="prose !max-w-none leading-8"
            on:click={handleClick}
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