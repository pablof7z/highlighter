<script lang="ts">
    import { NDKEvent, NDKHighlight, NDKTag } from "@nostr-dev-kit/ndk";
    import { ndk } from "$stores/ndk";
	import { EventContent } from "@nostr-dev-kit/ndk-svelte-components";
	import HighlightedContent from "./HighlightedContent.svelte";
	import UpgradeButton from "$components/buttons/UpgradeButton.svelte";
	import HighlightingArea from "../HighlightingArea.svelte";
	import { getContext, onMount } from "svelte";
	import { Readable } from "svelte/store";
	import { Button } from "$components/ui/button";
	import { footerMainView } from "$stores/layout";
	import * as Content from "$components/Content";

    export let article: NDKEvent;
    export let isPreview = false;
    export let isFullVersion = true;

    $: isFullVersion = !article.tagValue('full');

    const highlights = getContext('highlights') as Readable<NDKHighlight[]>;

    let el: HTMLDivElement;

    onMount(() => {
        const rect = el.getBoundingClientRect();
        console.log(rect);
    })
</script>

<div class="break-inside max-sm:ml-4 max-sm:mr-12 relative" bind:this={el}>
    {#if !isPreview}
        <HighlightingArea>
            <HighlightedContent event={article} highlights={highlights} />

            {#if !isFullVersion}
                <div class="absolute bottom-0 right-0 bg-gradient-to-t from-background to-transparent via-background/70 w-full h-full flex flex-col items-center justify-center">
                    <UpgradeButton event={article} />
                </div>
            {/if}
        </HighlightingArea>
    {:else}
        <EventContent
            ndk={$ndk}
            event={article}
            class="prose-lg leading-8"
        />
    {/if}
</div>

{#if !isPreview}
    <div class="flex flex-row w-full items-center justify-between border-y border-border py-2">
        <h2 class="mb-0 grow">Comments</h2>

        <Button on:click={() => $footerMainView = 'comment'}>
            Write a comment
        </Button>
    </div>

    <div class=" min-h-[20rem]">
        <Content.Views.Comments wrappedEvent={article} />
    </div>
{/if}