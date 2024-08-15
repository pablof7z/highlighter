<script lang="ts">
	import Avatar from "$components/User/Avatar.svelte";
	import { Hexpubkey } from "@nostr-dev-kit/ndk";

    export let pubkeys: Hexpubkey[];
    export let size = "xs";
    export let count = 5;

    let p: Hexpubkey[];
    $: p = Array.from(new Set(pubkeys));
</script>

<div class="flex flex-row items-center rounded-full overflow-clip h-auto">
    <div class="flex flex-row items-center -space-x-2">
        {#each p.slice(0, count) as pubkey (pubkey)}
            <div class="flex flex-row items-center space-x-1">
                <Avatar {pubkey} {size} />
            </div>
        {/each}
    </div>
</div>
