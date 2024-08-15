<script lang="ts">
    import { ndk } from "$stores/ndk.js";
    import { NDKKind, NDKList } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";
    import * as Feed from "$components/Feed";
	import { filterLists } from "$utils/curation-filter";

    onDestroy(() => {
        curations.unsubscribe();
    })

    const curations = $ndk.storeSubscribe([
        { kinds: [NDKKind.ArticleCurationSet], limit: 50 }
    ], undefined, NDKList);
</script>

<Feed.Curations
    store={filterLists(curations)}
/>