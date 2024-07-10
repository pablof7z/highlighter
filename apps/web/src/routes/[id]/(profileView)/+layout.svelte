<script lang="ts">
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import { resetLayout } from '$stores/layout';
	import { onDestroy } from 'svelte';
	import { NDKUser } from '@nostr-dev-kit/ndk';
	import { getUserFromUrlId } from '$utils/user/from-url-id';
    import * as User from "$components/User";
	import UserProfile from '$components/User/UserProfile.svelte';

    let id: string;
    let user: NDKUser | undefined = undefined;

    $: if (id !== $page.params.id) {
        id = $page.params.id;
        getUserFromUrlId(id).then(({user: u}) => {
            console.log('getUserFromUrlId', u)
            user = u;
            if (user) user.ndk = $ndk;
        });
    }

    onDestroy(resetLayout);
</script>

{#key user?.pubkey}
    {#if user}
        <UserProfile {user} let:userProfile let:fetching let:authorUrl>
            <User.Shell {user} {userProfile} {fetching} {authorUrl}>
                <slot />
            </User.Shell>
        </UserProfile>
    {/if}
{/key}