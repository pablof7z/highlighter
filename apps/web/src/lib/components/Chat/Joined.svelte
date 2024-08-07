<script lang="ts">
	import Name from "$components/User/Name.svelte";
    import { NDKEvent } from "@nostr-dev-kit/ndk";

    export let event: NDKEvent;
    const pubkey = event.tagValue("p")
</script>

<div class="text-muted-foreground text-center text-sm">
    <Name {pubkey} />
    entered the chat
</div>