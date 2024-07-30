<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext, onDestroy } from 'svelte';
    import { NDKArticle, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { layout } from '$stores/layout';
	import { ndk } from '$stores/ndk';

    $layout.fullWidth = false;
    
    export let user = getContext('user') as NDKUser;
    const articles = $ndk.storeSubscribe({ kinds: [NDKKind.Article], authors: [user.pubkey]}, undefined, NDKArticle)

    onDestroy(() => articles.unsubscribe())
</script>

<div class="responsive-padding">
    <Feed.Articles
        store={articles}
        skipAuthor
    />
</div>