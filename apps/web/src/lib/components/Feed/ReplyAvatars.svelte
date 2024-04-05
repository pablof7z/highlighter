<script lang="ts">
	import { Avatar } from "@kind0/ui-common";
	import { Hexpubkey } from "@nostr-dev-kit/ndk";

    export let users: Hexpubkey[];
</script>

{#if users.length >= 1}
    <Avatar size="small" class="!w-8 !h-8 m-[2px]" type="circle" pubkey={users[0]} />

    {#if users.length >= 2}
        <div class="flex items-center">
            <Avatar size="small" class="m-[2px] !w-6 !h-6" type="circle" pubkey={users[1]} />
            {#if users.length >= 3}
                <Avatar size="small" class="m-[2px] !w-4 !h-4" type="circle" pubkey={users[2]} />
            {/if}
        </div>
    {/if}
{/if}