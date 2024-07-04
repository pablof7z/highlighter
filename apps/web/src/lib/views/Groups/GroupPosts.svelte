<script lang="ts">
	import GroupPosts from './GroupPosts.svelte';
	import { pageHeader } from "$stores/layout";
    import ChatInput from "$components/Chat/Input.svelte";
	import { ndk } from "$stores/ndk";
	import { NDKEvent, NDKKind, NDKSimpleGroup, NDKTag } from "@nostr-dev-kit/ndk";
	import { onDestroy } from "svelte";
	import { derived } from "svelte/store";
	import StoreFeed from '$components/Feed/StoreFeed.svelte';
	import NewPost from '$components/Feed/NewPost/NewPost.svelte';

    export let group: NDKSimpleGroup;

    $: if ($pageHeader) {
        $pageHeader.title = group.name;
    }

    const posts = $ndk.storeSubscribe([
        {kinds: [NDKKind.GroupNote], "#h": [group.groupId]},
        {kinds: [NDKKind.GroupReply], "#h": [group.groupId]},
    ], { groupable: false, subId: 'group-content', relaySet: group.relaySet });

    // const replies = $ndk.storeSubscribe([
    //     {kinds: [NDKKind.GroupReply], "#h": [group.groupId]},
    // ], { groupable: false, subId: 'group-content', relaySet: group.relaySet });

    // const sortedPosts = derived([ posts, replies ], ([$posts, $replies]) => {

    // });

    // const onlyOp = derived(chat, ($chat) => {
    //     return $chat.filter((e: NDKEvent) => !e.tagValue("e"));
    // })

    onDestroy(() => {
        posts.unsubscribe();
    })

    let tags: NDKTag[] = [ [ "h", group.groupId ] ];

    $: if ($posts.length > 0) {
        tags = tags.filter((t) => t[0] !== "previous");

        const previous = $posts.slice(0, 10)
            .map(e => e.id.slice(0, 8))
        
        tags.push([ "previous", ...previous ]);
    }
</script>

<StoreFeed feed={posts} />

<NewPost
    kind={NDKKind.GroupNote}
    extraTags={tags}
    relaySet={group.relaySet}
/>