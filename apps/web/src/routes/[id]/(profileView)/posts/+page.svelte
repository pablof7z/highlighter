<script lang="ts">
	import { page } from "$app/stores";
	import ForumFeed from "$components/Feed/ForumFeed.svelte";
	import { NDKKind, NDKTag, NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;
    let newPostTags: NDKTag[] = [];

    $: {
        user = $page.data.user;
        newPostTags = [
            [ "h", user.pubkey ]
        ]
    }
</script>

{#key user.pubkey}
    <ForumFeed
        newPostKind={NDKKind.GroupNote}
        showNewPost={true}
        filters={[
            { kinds: [NDKKind.GroupNote, NDKKind.GroupReply], "#h": [user.pubkey] }
        ]}
        {newPostTags}
    />
{/key}