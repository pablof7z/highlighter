<script lang="ts">
	import { page } from "$app/stores";
	import ForumFeed from "$components/Feed/ForumFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { NDKKind, NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10 text-lg">
    <ForumFeed
        filters={[
            { kinds: [NDKKind.Text], authors: [user.pubkey], limit: 50 },
        ]}
        showNewPost={user.pubkey === $currentUser?.pubkey}
        newPostKind={NDKKind.Text}
    />
</div>