<script lang="ts">
	import { page } from "$app/stores";
	import CreatorFeed from "$components/Feed/CreatorFeed.svelte";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<CreatorFeed onlyBackstageContent={true} />