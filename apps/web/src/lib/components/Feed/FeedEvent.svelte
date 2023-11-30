<script lang="ts">
	import NDK, { NDKArticle, NDKKind, type NDKEvent } from "@nostr-dev-kit/ndk";
	import FeedArticle from "./FeedArticle.svelte";
	import FeedGroupPost from "./FeedGroupPost.svelte";
	import { user } from "@kind0/ui-common";

    export let event: NDKEvent;
</script>

<div class="w-full">
    {#if event.kind === NDKKind.GroupNote}
        <FeedGroupPost {event} />
    {:else if event.kind === NDKKind.Article}
        <FeedArticle article={NDKArticle.from(event)} />
    {/if}
</div>