<script lang="ts">
	import Avatar from "$components/User/Avatar.svelte";
	import { Hexpubkey } from "@nostr-dev-kit/ndk";

    export let pubkeys: Hexpubkey[];
    export let size = "tiny";
</script>

<div class="flex flex-row items-center rounded-full overflow-clip">
    <div class="flex flex-row items-center -space-x-2">
        {#each pubkeys as pubkey}
            <div class="flex flex-row items-center space-x-1">
                <Avatar {pubkey} {size} />
            </div>
        {/each}
    </div>
</div>
