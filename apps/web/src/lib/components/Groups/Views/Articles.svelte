<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext } from 'svelte';
	import { Readable } from 'svelte/store';
    import { NDKArticle, NDKKind, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { layout } from '$stores/layout';
	import { ndk } from '$stores/ndk';

    $layout.fullWidth = false;
    
    export let group = getContext('group') as NDKSimpleGroup;

    const groupArticles = $ndk.storeSubscribe([
        { kinds: [NDKKind.Article], "#h": [ group.groupId ] },
    ], {
        relaySet: group.relaySet
    }, NDKArticle)
</script>

<div class="responsive-padding">
    <Feed.Articles
        store={groupArticles}
    />
</div>