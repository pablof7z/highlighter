<script lang="ts">
	import { page } from "$app/stores";
	import Highlights from "$components/Highlights.svelte";
	import { layoutMode } from "$stores/layout";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    $layoutMode = "single-column-focused";
    
    let user: NDKUser;

    $: user = $page.data.user;
</script>

<Highlights
    filter={{"authors": [user.pubkey]}}
/>