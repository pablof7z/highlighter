<script lang="ts">
    import { page } from "$app/stores";
    import type { NDKUser } from "@nostr-dev-kit/ndk";
    import { onDestroy } from "svelte";
	import { startUserView, userSubscription } from "$stores/user-view";

    export let user: NDKUser = $page.data.user;

    $: {
        console.log('$: user in layout.svelte', user);
        user = $page.data.user;

        try {
            if (user && user.npub) {
                npub = user.npub;
                startUserView(user);
            }
        } catch {}
    }

    let npub: string;

    // $: npub = $page.data.npub;



    console.log('user in layout.svelte', user);

    onDestroy(() => {
        userSubscription?.unref();
    })
</script>

{#if npub}
    {#key user.pubkey}
        <slot />
    {/key}
{:else}
    <div class="flex flex-col items-center justify-center h-full">
        No user found
    </div>
{/if}