<script lang="ts">
	import { ndk } from "@kind0/ui-common";
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import { userFollows } from "$stores/session";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";

    const filters: NDKFilter[] = [
        {
            kinds: [NDKKind.Article],
            authors: Array.from($userFollows)
        }
    ]
</script>

<FilterFeed {filters} renderLimit={50} />