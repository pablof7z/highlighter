<script lang="ts">
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from "$stores/session";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";

    const authors = Array.from($userFollows);

    if ($currentUser) authors.push($currentUser.id);

    const filters: NDKFilter[] = [
        {
            kinds: [NDKKind.Highlight, NDKKind.Text, NDKKind.Article, NDKKind.HorizontalVideo],
            authors, limit: 100
        }
    ]
</script>

<FilterFeed
    {filters}
    newPostKind={NDKKind.Text}
    urlPrefix="/e/"
    renderLimit={1}
/>