<script lang="ts">
	import { Avatar, Name } from '@kind0/ui-common';
	import { NDKUser, type Hexpubkey } from '@nostr-dev-kit/ndk';
    import UserProfile from '$components/User/UserProfile.svelte';
    import { user as currentUser } from '@kind0/ui-common';
	import type { Readable } from 'svelte/motion';
    export let user: NDKUser;

    export let supporters: Readable<Record<Hexpubkey, string | undefined>>;

    let supportingPubkeys: Set<Hexpubkey> = new Set<Hexpubkey>();
    let isCurrentUser: boolean;
    let isSupporter: boolean;

    $: if (supporters && $supporters) {
        supportingPubkeys = new Set(Object.keys($supporters));
    }

    $: isCurrentUser = user && user?.pubkey === $currentUser?.pubkey;
    $: isSupporter = supportingPubkeys.has($currentUser?.pubkey);
</script>

<div class="border border-base-300 w-full p-4 {$$props.class??""}">
    {#each Array.from(supportingPubkeys) as supporterPubkey (supporterPubkey)}
        <UserProfile pubkey={supporterPubkey} let:userProfile let:fetching let:authorUrl>
            <a href={authorUrl} class="flex flex-row gap-2 items-center">
                <Avatar pubkey={supporterPubkey} {userProfile} {fetching} size="small" />
                <Name pubkey={supporterPubkey} {userProfile} {fetching} />
            </a>
        </UserProfile>
    {/each}
</div>