<script lang="ts">
	import { OpenFn } from "$components/Footer";
	import HighlightBody from "$components/HighlightBody.svelte";
	import currentUser from "$stores/currentUser";
    import { layout } from "$stores/layout";
	import { openModal } from "$utils/modal";
	import NDK, { NDKArticle, NDKHighlight } from "@nostr-dev-kit/ndk";
	import { Repeat, Quotes, ChatCircle, X } from "phosphor-svelte";

    export let open: OpenFn;
    export let article: NDKArticle;
    export let hideCollapsedView: boolean;
    const highlight: NDKHighlight = $layout.footer?.props?.highlight;

    hideCollapsedView = true;

    if (!highlight) {
        console.warn('No highlight provided to HighlightViewer');
        open(false);
    }
</script>

{#if highlight}
    <div class="bg-secondary p-3 rounded border">
        <HighlightBody
            {highlight}
            skipArticle
            skipHighlighter={highlight.pubkey === $currentUser?.pubkey}
        />

        {#if highlight.pubkey !== $currentUser?.pubkey}

        {/if}
    </div>
{/if}