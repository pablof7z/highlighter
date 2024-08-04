<script lang="ts">
	import { NDKEvent, NDKKind, NDKTag, NostrEvent } from '@nostr-dev-kit/ndk';
	import LogoGradient from "$icons/LogoGradient.svelte";
	import { getParagraph } from '$utils/text';
	import { onMount } from 'svelte';
	import { ndk } from "$stores/ndk";
	import { pushState } from '$app/navigation';
	import HighlightTool from '$components/HighlightArea/HighlightTool.svelte';

    export let tags: NDKTag[] = [];

    let container: HTMLElement;

    let highlightTags: NDKTag[] = [
        ["alt", 'This is a highlight created in https://highlighter.com'],
        ...tags
    ];
</script>

{#if container}
    <HighlightTool contentContainer={container} tags={highlightTags} />
{/if}

<article bind:this={container} class={$$props.class??""}>
    <slot />
</article>


<style lang="postcss">
    :global(.article pre) {
        @apply mb-4;
    }

    :global(.article p), :global(.article ul), :global(.article li), :global(.article h1), :global(.article h2), :global(.article blockquote) {
        @apply relative;
    }

    :global(.article p::before), :global(.article blockquote::before) {
        @apply transition-opacity duration-300 ease-in;
        content: "";
        top: 0;
        left: -15px;
        @apply pl-4;
        height: 100%;
        position: absolute;
        @apply border-l-4 border-accent;
        @apply opacity-0;
    }
</style>