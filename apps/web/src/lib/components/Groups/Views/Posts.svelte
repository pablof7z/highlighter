<script lang="ts">
	import { layout, } from "$stores/layout";
	import { ndk } from "$stores/ndk";
	import { NDKKind, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import { Readable } from "svelte/store";
    import * as Groups from "$components/Groups";

    export let group: Readable<Groups.Group>;
    export let optionManager;

    $layout.footerInMain = true;
        
    const posts = $ndk.storeSubscribe([
        {kinds: [NDKKind.GroupNote], "#h": [$group.id]},
        {kinds: [NDKKind.GroupReply], "#h": [$group.id]},
    ], { groupable: false, subId: 'group-content', relaySet: $group.relaySet });

    onDestroy(() => {
        posts.unsubscribe();
    })

    let tags: NDKTag[] = [ [ "h", $group.id ] ];

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
