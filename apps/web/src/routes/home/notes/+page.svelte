<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from "$stores/session";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { onMount } from "svelte";
	import NewPost from "$components/Feed/NewPost/NewPost.svelte";

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

<div class="w-full hidden sm:block">
    <NewPost
        kind={NDKKind.Text}
        placeholder="What's happening?!"
        autofocus={false}
    />
</div>

{#if filters}
    <FilterFeed
        {filters}
        urlPrefix="/e/"
        renderLimit={1}
    />
{/if}