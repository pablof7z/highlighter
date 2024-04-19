<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from "$stores/session";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";

    const filters: NDKFilter[] = [
        {
            kinds: [NDKKind.Highlight, NDKKind.Text, NDKKind.Article, NDKKind.HorizontalVideo],
            authors: Array.from($userFollows),
            limit: 10
        }
    ]
</script>

<FilterFeed
    {filters}
    newPostKind={NDKKind.Text}
    urlPrefix="/e/"
    renderLimit={100}
/>