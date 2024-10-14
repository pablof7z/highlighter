<script lang="ts">
	import HighlightTool from '$components/HighlightArea/HighlightTool.svelte';

    let container: HTMLElement;
</script>

{#if container}
    <HighlightTool contentContainer={container} />
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
        /* @apply hover:bg-secondary cursor-pointer; */
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