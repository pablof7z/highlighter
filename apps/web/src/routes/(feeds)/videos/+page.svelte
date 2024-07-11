<script lang="ts">
	import { NDKArticle, NDKKind, NDKVideo } from "@nostr-dev-kit/ndk";
	import { layoutMode } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { wot, wotFiltered, wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";

    $layoutMode = "full-width";

    const videos = $ndk.storeSubscribe(
        { kinds: [NDKKind.HorizontalVideo], limit: 200 },
        { subId: 'home-videos' },
        NDKVideo
    );

    const wotF = wotFilteredStore(videos) as Readable<NDKArticle[]>;

    const filteredVideos = derived(wotF, ($wotF) => {
        return $wotF;
        // return filterArticle(wotF);
    });

    onDestroy(() => {
        videos.unsubscribe();
    });
</script>

<div class="mx-auto w-full">
    <StoreGrid feed={filteredVideos} renderLimit={1} />
</div>