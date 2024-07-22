<script lang="ts">
	import { layout, pageHeader } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKSimpleGroupMetadata, NDKTag } from "@nostr-dev-kit/ndk";
	import { getContext, onDestroy } from "svelte";
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { Readable } from "svelte/store";
    import * as Groups from "$components/Groups";

    const group = getContext('group') as NDKSimpleGroup;
    const metadata = getContext("groupMetadata") as Readable<NDKSimpleGroupMetadata>;
    const isMember = getContext("isMember") as Readable<boolean>;
        
    const posts = $ndk.storeSubscribe([
        {kinds: [NDKKind.GroupNote], "#h": [group.groupId]},
        {kinds: [NDKKind.GroupReply], "#h": [group.groupId]},
    ], { groupable: false, subId: 'group-content', relaySet: group.relaySet });

    onDestroy(() => {
        posts.unsubscribe();
    })

    let tags: NDKTag[] = [ [ "h", group.groupId ] ];

    $layout.footer = {
        component: Groups.Footers.Post,
        props: { tags, group, kind: NDKKind.GroupNote, placeholder: "Say something..." }
    };

    $: if ($posts.length > 0) {
        tags = tags.filter((t) => t[0] !== "previous");

        const previous = $posts.slice(0, 10)
            .map(e => e.id.slice(0, 8))
        
        tags.push([ "previous", ...previous ]);
    }
</script>

<StoreFeed feed={posts} />
