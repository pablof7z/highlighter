<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext, onDestroy } from 'svelte';
    import { NDKVideo, NDKKind, NDKUser } from "@nostr-dev-kit/ndk";
	import { layout } from '$stores/layout';
	import { ndk } from '$stores/ndk';

    $layout.fullWidth = false;
    
    export let user = getContext('user') as NDKUser;
    const Videos = $ndk.storeSubscribe([
        { kinds: [NDKKind.HorizontalVideo, NDKKind.VerticalVideo], authors: [user.pubkey]}
    ], undefined, NDKVideo)

    onDestroy(() => Videos.unsubscribe())
</script>

<div class="responsive-padding">
    <Feed.Videos
        store={Videos}
        skipAuthor
    />
</div>