hello
<!-- <script lang="ts">
	import CreatorShell from '$components/Creator/CreatorShell.svelte';
	import { page } from "$app/stores";
	import { ndk } from "$stores/ndk.js";
	import { resetLayout } from '$stores/layout';
	import { onDestroy } from 'svelte';
	import { NDKUser } from '@nostr-dev-kit/ndk';
	import { getUserFromUrlId } from '$utils/user/from-url-id';

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
        <CreatorShell {user}>
            <slot />
        </CreatorShell>
    {/if}
{/key} -->