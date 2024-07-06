<script lang="ts">
	import GroupPosts from './GroupPosts.svelte';
	import { layout, pageHeader } from "$stores/layout";
    import ChatInput from "$components/Chat/Input.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import NewPost from '$components/Feed/NewPost/NewPost.svelte';
	import Footer from '$components/PageElements/Mobile/Footer.svelte';

    export let group: NDKSimpleGroup;

    const posts = $ndk.storeSubscribe([
        {kinds: [NDKKind.GroupNote], "#h": [group.groupId]},
        {kinds: [NDKKind.GroupReply], "#h": [group.groupId]},
    ], { groupable: false, subId: 'group-content', relaySet: group.relaySet });

    onDestroy(() => {
        posts.unsubscribe();
    })

    let tags: NDKTag[] = [ [ "h", group.groupId ] ];

    $layout.footer = {
        component: Footer,
        props: { tags, group, kind: NDKKind.GroupNote, placeholder: "Say something..." }
    }

    $: if ($posts.length > 0) {
        tags = tags.filter((t) => t[0] !== "previous");

        const previous = $posts.slice(0, 10)
            .map(e => e.id.slice(0, 8))
        
        tags.push([ "previous", ...previous ]);
    }
</script>

<StoreFeed feed={posts} />
