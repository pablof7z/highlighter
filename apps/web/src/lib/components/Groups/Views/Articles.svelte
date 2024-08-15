<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext, onDestroy } from 'svelte';
	import { Readable } from 'svelte/store';
    import { NDKArticle, NDKKind, NDKSimpleGroup } from "@nostr-dev-kit/ndk";
	import { layout } from '$stores/layout';
	import { GroupData } from '..';

    $layout.fullWidth = false;
    
    export let group = getContext('group') as Readable<GroupData>;
</script>

<div class="responsive-padding">
    <Feed.Root
        filters={[
            { kinds: [NDKKind.Article], "#h": [ $group.id ] },
        ]}
        opts={{ relaySet: $group.relaySet }}
        type={NDKArticle}
        let:store
    >
        <Feed.Articles
            {store}
            itemProps={{
                skipCommunity: true,
                ...$$props.itemProps??{}
            }}
        />
    </Feed.Root>
</div>