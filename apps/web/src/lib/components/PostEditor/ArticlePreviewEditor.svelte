<script lang="ts">
	import GuideToPreviews from './../../drawer/help/guide-to-previews.svelte';
	import ArticleEditor from "$components/Forms/ArticleEditor.svelte";
	import Box from "$components/PageElements/Box.svelte";
	import { preview, previewContentChanged, previewTitleChanged } from "$stores/post-editor";
	import { ndk, pageDrawerToggle } from "@kind0/ui-common";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
    import truncateMarkdown from 'markdown-truncate';
	import { Info } from "phosphor-svelte";

    export let article: NDKArticle;

    let previewContentReadLink: string;
    const domain = "https://highlighter.com";
    let authorLink: string = domain;
    let authorUrl: string | undefined;
    $: authorLink = authorUrl ? `${domain}${authorUrl}` : domain;
    $: previewContentReadLink = `\n\n--------------------------\n\nSupport my work and read the rest of this article on my Highlighter page: ${authorLink}`;

    function generatePreviewContent() {
        const limit = Math.min(1500, article.content.length * 0.4);
        let previewContent = truncateMarkdown(article.content, {
            limit,
            ellipsis: true
        });

        previewContent += previewContentReadLink;

        return previewContent;
    }

    $preview ??= new NDKArticle($ndk, {
        content: generatePreviewContent(),
    } as NostrEvent);

    if (!$previewTitleChanged) $preview.title = article.title;
    if (!$previewContentChanged) $preview.content = generatePreviewContent();

    function openGuide() {
        if (!$pageDrawerToggle) {
            $pageDrawerToggle = true;
            const $rightSidebar = {
                component: GuideToPreviews,
                props: {}
            }
        } else {
            $pageDrawerToggle = false;
        }
    }
</script>

<Box innerClass="!flex-row justify-between items-center">
    <h3 class="text-white text-sm">
        <Info class="w-4 h-4 text-info inline ml-2" />
        You're editing your article's teaser for non-subscribers
    </h3>

    <!-- <button class="button" on:click={openGuide}>
        How to write a good teaser
    </button> -->
</Box>

<ArticleEditor article={$preview} on:titleChanged={() => $previewTitleChanged = true} on:contentChanged={() => $previewContentChanged = true} />