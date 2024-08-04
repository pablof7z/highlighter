<script lang="ts">
	import { NDKArticle, NDKKind, NDKVideo } from "@nostr-dev-kit/ndk";
	import { layout, layoutMode } from "$stores/layout";
	import { onDestroy } from "svelte";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { wot, wotFiltered, wotFilteredStore } from "$stores/wot";
	import { ndk } from "$stores/ndk.js";
	import { Readable, derived } from "svelte/store";
    import * as Feed from "$components/Feed";

    $layout.sidebar = false;
    $layout.fullWidth = true;
    $layout.title = "Watch";
    $layout.back = { url: "/" };
    $layout.navigation = false;

    const videos = $ndk.storeSubscribe(
        { kinds: [NDKKind.HorizontalVideo], limit: 200 },
        { subId: 'home-videos' },
        NDKVideo
    );

    const wotF = wotFilteredStore(videos) as Readable<NDKVideo[]>;

    const filteredVideos = derived(wotF, ($wotF) => {
        return $wotF;
        // return filterArticle(wotF);
    });

    onDestroy(() => {
        videos.unsubscribe();
    });
</script>

<div class="responsive-padding w-full">
    <Feed.Videos
        gridSetup="xl:grid-cols-4"
        store={filteredVideos}
        skipAuthor
    />
</div>
