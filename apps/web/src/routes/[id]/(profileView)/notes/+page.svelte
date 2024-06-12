<script lang="ts">
	import { page } from "$app/stores";
	import FilterFeed from "$components/Feed/FilterFeed.svelte";
	import currentUser from "$stores/currentUser";
	import { layoutMode } from "$stores/layout";
	import { NDKKind, NDKUser } from "@nostr-dev-kit/ndk";

    $layoutMode = "single-column-focused";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10 sm:text-lg">
    <FilterFeed
        filters={[
            { kinds: [NDKKind.Text], authors: [user.pubkey], limit: 200 },
        ]}
        renderLimit={1}
        newPostKind={user.pubkey === $currentUser?.pubkey ? NDKKind.Text : undefined}
    />
</div>