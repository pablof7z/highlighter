<script lang="ts">
	import Name from "$components/User/Name.svelte";
import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
</script>

<div class="text-muted-foreground text-center text-sm">
    <Name pubkey={event.pubkey} />
    requested to join
</div>