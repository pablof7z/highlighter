<script lang="ts">
	import { page } from "$app/stores";
	import Curations from "$components/Curations.svelte";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-row gap-10">
    <Curations
        filter={{"authors": [user.pubkey]}}
        skipAuthor={true}
    />
</div>