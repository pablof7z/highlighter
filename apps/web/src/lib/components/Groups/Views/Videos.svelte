<script lang="ts">
    import * as Feed from '$components/Feed';
	import { getContext } from 'svelte';
    import {  NDKKind, NDKVideo } from "@nostr-dev-kit/ndk";
	import { layout } from '$stores/layout';
	import { ndk } from '$stores/ndk';
	import { Readable } from 'svelte/store';
	import { Group } from '..';

    $layout.fullWidth = false;
    
    export let group = getContext('group') as Readable<Group>;

    const groupVideos = $ndk.storeSubscribe([
        { kinds: [NDKKind.HorizontalVideo, NDKKind.VerticalVideo], "#h": [ $group.id ] },
    ], {
        relaySet: $group.relaySet
    }, NDKVideo)
</script>

<div class="responsive-padding">
    <Feed.Videos
        store={groupVideos}
    />
</div>