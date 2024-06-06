<script lang="ts">
	import { slide } from 'svelte/transition';
    import Input from '$components/ui/input/input.svelte';
    import { makePublicAfter, preview, previewExtraContent } from "$stores/post-editor";
	import Box from "$components/PageElements/Box.svelte";
	import { previewContentChanged, previewTitleChanged } from "$stores/post-editor";
	import { NDKArticle, type NostrEvent } from "@nostr-dev-kit/ndk";
    import truncateMarkdown from 'markdown-truncate';
	import { Info } from "phosphor-svelte";
	import MakePublicAfter from '$components/Editor/Audience/MakePublicAfter.svelte';
	import { ndk } from '$stores/ndk';

    export let article: NDKArticle;
    export let authorUrl: string = "";

    let previewContentReadLink: string;
    const domain = "https://highlighter.com";
    let authorLink = `${domain}${authorUrl}`;
    previewContentReadLink = `Support my work and read the rest of this article on my Highlighter page: ${authorLink}`;

    $previewExtraContent ??= { before: undefined, after: previewContentReadLink};

    $: if (Number($makePublicAfter) > 0) {
        $previewExtraContent!.before = makePublicNotice();
    }

    function makePublicNotice() {
        return `This is a preview of my subscribers-first article. The full version will be made public in ${$makePublicAfter} days.`;
    }

    function generatePreviewContent() {
        let limit = Math.min(1000, article.content.length * 0.4);
        if (limit > 2000) limit = 2000;
        let previewContent = truncateMarkdown(article.content, {
            limit,
            ellipsis: true
        });
        previewContent ??= "";

        return previewContent;
    }

    $preview ??= new NDKArticle($ndk, {
        content: generatePreviewContent(),
    } as NostrEvent);

    if ($preview.content.length === 0) {
        $preview.content = generatePreviewContent();
    }

    if (!$previewTitleChanged) $preview.title = article.title;
    if (!$previewContentChanged) $preview.content = generatePreviewContent();

    function openGuide() {
    }
</script>

<Box innerClass="">
    <h3 class="text-foreground text-sm">
        <Info class="w-4 h-4 text-info inline ml-2" />
        You're editing your article's preview for non-subscribers
    </h3>

    <MakePublicAfter />

    <!-- <button class="button" on:click={openGuide}>
        How to write a good preview
    </button> -->
</Box>

{#if $preview}
<div class="flex flex-col border-none border-neutral-800 sm:rounded-xl border">
    <div class="p-6 pb-0 w-full">
        <Input
            bind:value={$preview.title}
            color="black"
            class="!bg-transparent text-2xl border-none !p-0 rounded-lg focus:ring-0 text-foreground font-['InterDisplay'] font-semibold placeholder:text-foreground/50 placeholder:font-normal"
            placeholder="Add a title"
            on:change={() => $previewTitleChanged = true}
        />
    </div>
    <div class="p-6 pt-0 flex flex-col">
        {#if Number($makePublicAfter) > 0}
            <div class="flex flex-col justify-stretch w-full" transition:slide>
                <textarea
                    bind:value={$previewExtraContent.before}
                    class="
                        !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                        focus:ring-0
                        resize-none min-h-[5rem] text-neutral-400
                        {$$props.textareaClass??""}
                    "
                />
                <div class="border-b border-neutral-700 pb-2"></div>
            </div>
        {/if}
        <textarea
            bind:value={$preview.content}
            on:change={() => $previewContentChanged = true}
            class="
                !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                focus:ring-0
                resize-none  text-neutral-400
                {$$props.textareaClass??""}
            "
            placeholder="Write your heart out..."
        />
        <div class="border-t border-neutral-700 pt-4"></div>
        <textarea
            bind:value={$previewExtraContent.after}
            class="
                !bg-transparent text-lg border-none !px-4 -mx-4 rounded-lg
                focus:ring-0
                resize-none min-h-[5rem]  text-neutral-400
                {$$props.textareaClass??""}
            "
            placeholder="Add a call to action or a link to your Highlighter page"
        />
    </div>
</div>
{/if}
