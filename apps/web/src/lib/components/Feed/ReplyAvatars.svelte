<script lang="ts">
	import { networkFollows } from "$stores/session";
	import Avatar from '$components/User/Avatar.svelte';
	import { Hexpubkey, NDKSubscriptionOptions } from "@nostr-dev-kit/ndk";

    export let users: Hexpubkey[];

    const subOpts: NDKSubscriptionOptions = { groupable: true, groupableDelay: 800, groupableDelayType: 'at-least' };

    let choosenAvatars: Hexpubkey[] = [];
    $: {
        try {
            choosenAvatars = users.map(pubkey => {
                return [ pubkey, $networkFollows.get(pubkey) ?? 0 ];
            }).sort((a, b) => b[1] - a[1]).map(a => a[0]).
                map(pubkey => pubkey as Hexpubkey)
                .slice(0, 3);
        } catch (e) {
        }
    }
</script>

{#if choosenAvatars.length >= 1}
    <div class="flex max-sm:flex-row max-sm:-space-x-2 flex-col items-center justify-end flex-none sm:w-16 max-sm:mt-4">
        {#key choosenAvatars[0]}
            <Avatar size="small" class="!w-6 !h-6 m-[2px]" type="circle" pubkey={choosenAvatars[0]} {subOpts} />
        {/key}

        {#if choosenAvatars.length >= 2}
            <div class="flex max-sm:items-end items-start max-sm:-space-x-2">
                {#key choosenAvatars[1]}
                    <Avatar size="small" class="m-[2px] !w-4 !h-4 max-sm:!w-6 max-sm:!h-6" type="circle" pubkey={choosenAvatars[1]} {subOpts} />
                {/key}
                {#if choosenAvatars.length >= 3}
                    {#key choosenAvatars[2]}
                        <Avatar size="small" class="m-[2px] !w-3 !h-3 max-sm:!w-6 max-sm:!h-6" type="circle" pubkey={choosenAvatars[2]} {subOpts} />
                    {/key}
                {/if}
            </div>
        {/if}
    </div>
{/if}