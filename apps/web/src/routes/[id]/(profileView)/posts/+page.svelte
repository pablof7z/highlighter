<script lang="ts">
	import { page } from "$app/stores";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
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
    <FilterFeed
        newPostKind={NDKKind.GroupNote}
        filters={[
            { kinds: [NDKKind.GroupNote, NDKKind.GroupReply], "#h": [user.pubkey] }
        ]}
        {newPostTags}
    />
{/key}