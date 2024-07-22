<script lang="ts">
	import { NDKArticle, NDKEvent } from "@nostr-dev-kit/ndk";
    import Article from "./Article.svelte";

    export let item: NDKEvent;
</script>

{#if item instanceof NDKArticle}
    <Article article={item} />
{/if}