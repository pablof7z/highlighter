<script lang="ts">
	import { goto } from "$app/navigation";
	import { debugMode, userActiveSubscriptions } from "$stores/session";
	import { startUserView, userSubscription, userTiers } from "$stores/user-view";
	import { ndk, pageDrawerToggle, rightSidebar, user, HighlightWrapper, Avatar, Name, RelativeTime } from "@kind0/ui-common";
	import { NDKEvent, type NDKArticle, NDKKind, type NostrEvent, type NDKEventId } from "@nostr-dev-kit/ndk";
	import { onDestroy, onMount } from "svelte";
    import { getParagraph, getText } from "get-selection-more";
	import { getDefaultRelaySet } from '$utils/ndk';
	import ArticleRender from './ArticleRender.svelte';
	import ItemHeader from "$components/ItemHeader.svelte";

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

        console.log(highlight.content);
        content = content.replace(regexp, (match) => {
            appliedHighlightIds.add(highlight.id);
            return `<mark data-highlight-id="${highlight.id}">${match}</mark>`;
        })
        console.log(content);
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

        document.addEventListener('mouseup', function(event) {
            let selection = window.getSelection();
            if (selection.toString().length > 0) {
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
        await event.publish(
            getDefaultRelaySet()
        )
    }
</script>

<svelte:head>
    <title>{article.title}</title>
</svelte:head>

<ItemHeader item={article} />
<ArticleRender {article} {editUrl} {isFullVersion} />