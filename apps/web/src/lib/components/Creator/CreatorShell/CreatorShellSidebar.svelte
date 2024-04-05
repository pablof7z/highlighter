<script lang="ts">
	import TopZappedByList from "$components/User/TopZappedByList.svelte";
	import { NDKUser, type Hexpubkey } from "@nostr-dev-kit/ndk";
	import { Readable } from "svelte/store";
	import SidebarSupporters from "./SidebarSupporters.svelte";

    export let user: NDKUser;
    export let userSupporters: Readable<Record<Hexpubkey, string | undefined | true>>;
</script>

<div class="flex flex-col gap-10 h-full">
	<SidebarSupporters {user} />

	<TopZappedByList {user} />
</div>
