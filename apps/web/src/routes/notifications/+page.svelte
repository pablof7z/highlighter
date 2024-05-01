<script lang="ts">
	import currentUser from '$stores/currentUser';
	import { NDKFilter, NDKKind } from "@nostr-dev-kit/ndk";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import { pageMainContentMaxWidth } from '$stores/layout';

    $pageMainContentMaxWidth = 'max-w-3xl';

    const filters: NDKFilter[] = [
        {
            kinds: [NDKKind.Highlight, NDKKind.Text, NDKKind.Article, NDKKind.HorizontalVideo],
            "#p": [$currentUser!.pubkey],
            limit: 100
        }
    ]
</script>

<FilterFeed {filters} />

<!-- <LoadingScreen ready={!!mounted && !!$user}>
    <MainWrapper class="flex flex-col gap-10">
        <CreatorActivity />
    </MainWrapper>
</LoadingScreen> -->