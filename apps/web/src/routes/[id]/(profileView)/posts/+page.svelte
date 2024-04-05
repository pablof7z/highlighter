<script lang="ts">
	import { page } from "$app/stores";
	import ForumFeed from "$components/Feed/ForumFeed.svelte";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10">
    <ForumFeed {user} />
</div>