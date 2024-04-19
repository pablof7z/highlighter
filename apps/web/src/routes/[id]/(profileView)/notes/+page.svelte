<script lang="ts">
	import { page } from "$app/stores";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { NDKKind, NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10 sm:text-lg">
    <FilterFeed
        filters={[
            { kinds: [NDKKind.Text], authors: [user.pubkey], limit: 50 },
        ]}
        renderLimit={1}
        newPostKind={user.pubkey === $currentUser?.pubkey ? NDKKind.Text : undefined}
    />
</div>