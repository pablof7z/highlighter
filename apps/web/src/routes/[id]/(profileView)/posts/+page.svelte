<script lang="ts">
	import { page } from "$app/stores";
	import StoreGrid from "$components/Grid/StoreGrid.svelte";
	import { layoutMode } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";
	import { NDKEventStore } from "@nostr-dev-kit/ndk-svelte";
	import { onDestroy } from "svelte";

    $layoutMode = "full-width";
    
    let user: NDKUser;
    let newPostTags: NDKTag[] = [];

    let content: NDKEventStore<NDKEvent>;

    onDestroy(() => {
        content.unsubscribe();
    });

    $: {
        user = $page.data.user;
        newPostTags = [
            [ "h", user.pubkey ]
        ]

        if (content) content.unsubscribe();

        content = $ndk.storeSubscribe(
            { kinds: [NDKKind.Article, NDKKind.HorizontalVideo], "authors": [user.pubkey] },
            { subId: 'user-content' },
        );
    }
</script>

<div class="mx-auto w-full">
    <StoreGrid feed={content} renderLimit={1} />
</div>