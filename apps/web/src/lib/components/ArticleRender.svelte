<script lang="ts">
	import { getSummary } from '$utils/article';
	import HighlightIcon from '../icons/HighlightIcon.svelte';
	import { goto } from "$app/navigation";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import { userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription } from "$stores/user-view";
	import { ZapsButton, ndk } from "@kind0/ui-common";
	import { NDKEvent, type NDKArticle, NDKKind, type NostrEvent, type NDKEventId } from "@nostr-dev-kit/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import { onDestroy, onMount } from "svelte";
	import { CrownSimple, Lightning } from 'phosphor-svelte';
	import { getParagraph, getText } from '$utils/text';
	import LogoGradient from '$icons/LogoGradient.svelte';
	import ItemViewZaps from './ItemViewZaps.svelte';

    export let article: NDKArticle;
    const author = article.author;
    export let editUrl: string | undefined = undefined;
    export let isFullVersion: boolean;
    let content = article.content;

    const highlights = $ndk.storeSubscribe(
        { kinds: [NDKKind.Highlight], ...article.filter() },
        { subId: 'article-highlights' }
    )

    onMount(() => {
        startUserView(author);
    });

    onDestroy(() => {
        userSubscription?.unref();
        highlights?.unsubscribe();
    });

    const appliedHighlightIds = new Set<NDKEventId>();

    $: for (const highlight of $highlights) {
        if (appliedHighlightIds.has(highlight.id)) continue;

        const highlightContent = highlight.content.trim();
        // create regexp from highlight content (escape special characters)
        const regexp = new RegExp(highlightContent.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');

        content = content.replace(regexp, (match) => {
            appliedHighlightIds.add(highlight.id);
            return `<mark data-highlight-id="${highlight.id}">${match}</mark>`;
        })
    }

    // Check if this user has access to the full article and if they do, redirect them to the full article
    const fullTiers = article.getMatchingTags("tier").map(t => t[1]);

    $: if (fullTiers.includes($userActiveSubscriptions.get(article.pubkey))) {
        const parts = article.tagValue("full")?.split(/:/) as string[];
        const dTag = parts[2] || parts[0];
        goto(`/${author.npub}/${dTag}`);
    }

    editUrl ??= `/articles/${article.tagValue("d")}/edit`;

    onMount(() => {
        document.addEventListener('click', function(event) {
            // if the target is not the container nor a descendant of the container
            if (!el?.contains(event.target as Node)) {
                if (el?.classList.contains('opacity-0')) return;
                el?.classList.add('opacity-0');
            }
        });

        document.addEventListener('selectionchange', function(event) {
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

        document.addEventListener('mouseup', function(event) {
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
        document.addEventListener('mouseover', function(event) {
            const parentElement = event.target?.parentElement;
            if (!parentElement?.classList.contains('article')) return;
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
                        // remove opacity-0 class
                        // setTimeout(() => {
                        //     el?.appendChild(floatElement);
                        // }, 100)
                // })
            // }
        })

        // create a listener that fires when the document scrolls, when the user scrolls move the active paragraph float
        // to the first visible paragraph
        document.addEventListener('scroll', function(event) {
            // find the first visible paragraph
            const paragraphs = document.querySelectorAll('.article > p');
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
    })

    let el: HTMLDivElement;
    let paragraphFloat: HTMLDivElement;

    async function createParagraphHighlight() {
        const activeParagraphs = document.querySelectorAll('.active-paragraph');

        if (activeParagraphs.length === 0) return;

        const content = activeParagraphs[0].textContent;
        if (!content) return;

        const groupId = article.tagValue("h");
        const event = new NDKEvent($ndk, {
            kind: NDKKind.Highlight,
            content,
            tags: [
                [ "context", getParagraph() ]
            ]
        } as NostrEvent);

        // add h tag if it exists
        if (groupId) event.tags.push(["h", groupId]);

        event.tag(article);
        await event.sign();
        await event.publish()
    }

    async function createHighlight() {
        const content = getText();

        if (!content) return;

        const groupId = article.tagValue("h");
        const event = new NDKEvent($ndk, {
            kind: NDKKind.Highlight,
            content,
            tags: [
                [ "context", getParagraph() ]
            ]
        } as NostrEvent);

        // add h tag if it exists
        if (groupId) event.tags.push(["h", groupId]);

        event.tag(article);
        await event.sign();
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

<div class="w-full flex flex-col gap-4">
    {#if article.title}
        <div class="self-stretch text-white text-4xl font-semibold">
            {article.title}
        </div>
    {/if}

    <div class="text-xl text-white/70 font-normal">
        {getSummary(article)}
    </div>

    <ItemViewZaps event={article} />

    <div class="flex flex-row gap-4 flex-wrap">
        {#each article.getMatchingTags("t") as tag, i (i)}
            <div href="/?q={encodeURIComponent("#"+tag[1])}" class="flex-row gap-2 text-white/50 text-sm inline flex-inline bg-white/10 rounded-full px-3 py-1 whitespace-nowrap">
                <span>{tag[1]}</span>
            </div>
        {/each}
    </div>

    {#if article.image}
        <div class="w-full max-h-[50vh] relative overflow-hidden">
            <img class="w-full relative sm:rounded-xl object-cover object-top h-full" src={article.image} />
            <div class="absolute bottom-0 w-full h-2/5 bg-gradient-to-b from-transparent to-black"></div>
        </div>
    {/if}

    <div class="flex-col justify-start items-center gap-10 flex w-full max-sm:px-4">
        <div class="self-stretch justify-center items-start gap-8 inline-flex">
            <div class="grow shrink basis-0 flex-col justify-center items-start gap-10 inline-flex">
                <div class="self-stretch flex-col justify-center items-start flex">
                    <div class="self-stretch flex-col justify-start items-start gap-1 flex">

                    </div>
                    <article class="flex-col justify-start items-start gap-6 flex text-lg font-medium leading-8 w-full relative">
                        {#key content}
                            <EventContent ndk={$ndk} event={article} bind:content class="prose !max-w-none leading-8" />
                        {/key}

                        {#if !isFullVersion}
                            <div class="absolute bottom-0 right-0 bg-gradient-to-t from-black to-transparent via-black/70 w-full h-2/3 flex flex-col items-center justify-center">
                                <UpgradeButton event={article} />
                            </div>
                        {/if}
                    </article>
                </div>
            </div>
        </div>
    </div>
</div>

<style lang="postcss">
    :global(.float-element) {
        box-shadow: 0 0 10px #000;
    }

    :global(.article pre) {
        @apply mb-4;
    }

    :global(.article > p) {
        @apply relative;
    }

    :global(.article > *::before) {
        @apply transition-opacity duration-300 ease-in;
        content: "";
        top: 0;
        left: -10px;
        height: 100%;
        position: absolute;
        @apply border-l-4 border-accent2;
        @apply opacity-0;
    }

    :global(.active-paragraph::before) {
        @apply opacity-100;

    }
</style>
