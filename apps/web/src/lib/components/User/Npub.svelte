<script lang="ts">
	import { NDKUser } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;

    // last 6 digits of the pubkey
    const color = user.pubkey.slice(-6);
</script>

<div class="flex flex-row gap-2 items-center test-xs {$$props.class??""}">
    <span class="w-2 h-2 rounded-full" style="background-color: #{color};"></span>

    <span class="text-muted-foreground">
        {user.npub.slice(0,6)}..{user.npub.slice(-6)}
    </span>
</div>