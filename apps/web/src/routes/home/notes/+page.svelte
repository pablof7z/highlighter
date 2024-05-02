<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from "$stores/session";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { pageMainContentMaxWidth } from "$stores/layout";
	import { onMount } from "svelte";

    $pageMainContentMaxWidth = 'max-w-3xl';
    
    const authors = Array.from($userFollows);

    if ($currentUser) authors.push($currentUser.id);

    let filters: NDKFilter[];
    
    onMount(() => {
        filters = [{
            kinds: [NDKKind.Highlight, NDKKind.Text, NDKKind.Article, NDKKind.HorizontalVideo],
            authors, limit: 100
        }]
    });
</script>

{#if filters}
<FilterFeed
    {filters}
    newPostKind={NDKKind.Text}
    urlPrefix="/e/"
    renderLimit={1}
/>
{/if}