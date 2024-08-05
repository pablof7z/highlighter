<script lang="ts">
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
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
</script>

{#key user?.pubkey}
    {#if user}
        <UserProfile {user} let:userProfile let:fetching let:authorUrl>
            <User.Root {user} {userProfile} {fetching} {authorUrl} let:highlights let:notes let:articles let:videos let:wiki let:groupsList let:pinList let:tierList let:tiers let:eosed let:curations>
                <User.Shell {user} {userProfile} {authorUrl} {fetching} {highlights} {notes} {articles} {videos} {wiki} {groupsList} {pinList} {tierList} {tiers} {eosed} {curations}>
                    <slot />
                </User.Shell>
            </User.Root>
        </UserProfile>
    {/if}
{/key}