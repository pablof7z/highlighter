<script lang="ts">
	import { page } from "$app/stores";
	import SupporterList from "$components/Supporters/SupporterList.svelte";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    let user: NDKUser;

    $: user = $page.data.user;
</script>

<div class="flex flex-col discussion-wrapper">
    <SupporterList {user} />
</div>