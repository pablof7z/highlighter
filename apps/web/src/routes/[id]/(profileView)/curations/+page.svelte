<script lang="ts">
	import { page } from "$app/stores";
	import Curations from "$components/Curations.svelte";
	import { layoutMode } from "$stores/layout";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    $layoutMode = "single-column-focused";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10">
    <Curations
        filter={{"authors": [user.pubkey]}}
        skipAuthor={true}
    />
</div>