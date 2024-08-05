<script lang="ts">
	import { page } from "$app/stores";
	import Highlights from "$components/Highlights.svelte";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<Highlights
    filter={{"authors": [user.pubkey]}}
/>