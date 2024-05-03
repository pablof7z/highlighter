<script lang="ts">
	import TopZappedByList from "$components/User/TopZappedByList.svelte";
import { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;
</script>

<TopZappedByList {user} count={3} />