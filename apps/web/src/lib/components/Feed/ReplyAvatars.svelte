<script lang="ts">
	import { networkFollows } from "$stores/session";
	import Avatar from '$components/User/Avatar.svelte';
	import { Hexpubkey, NDKSubscriptionOptions } from "@nostr-dev-kit/ndk";

    export let users: Hexpubkey[];
    export let size = 'small';

    const subOpts: NDKSubscriptionOptions = { groupable: true, groupableDelay: 800, groupableDelayType: 'at-least' };

    let choosenAvatars: Hexpubkey[] = [];
    $: {
        const userSet = new Set(users);
        
        try {
            choosenAvatars = Array.from(userSet).map(pubkey => {
                return [ pubkey, $networkFollows.get(pubkey) ?? 0 ];
            }).sort((a, b) => b[1] - a[1]).map(a => a[0]).
                map(pubkey => pubkey as Hexpubkey)
                .slice(0, 3);
        } catch (e) {
        }
    }
</script>

{#if choosenAvatars.length >= 1}
    <div class="flex flex-row -space-x-3 items-center justify-end flex-none">
        {#each choosenAvatars as pubkey (pubkey)}
            <Avatar {size} class="mx-[2px]" type="circle" pubkey={pubkey} {subOpts} />
        {/each}
    </div>
{/if}