<script lang="ts">
	import { page } from "$app/stores";
	import ForumFeed from "$components/Feed/ForumFeed.svelte";
	import { NDKKind, NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10">
    <ForumFeed {user} filters={[
        { kinds: [NDKKind.Text], authors: [user.pubkey], limit: 50 },
    ]} showNewPost={false} />
</div>