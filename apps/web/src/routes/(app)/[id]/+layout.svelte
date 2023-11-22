<script lang="ts">
    import { page } from "$app/stores";
    import type { NDKUser } from "@nostr-dev-kit/ndk";
    import { ndk } from "@kind0/ui-common";
    import { onDestroy, onMount } from "svelte";
	import { startUserView, userSubscription } from "$stores/user-view";

    //let npub = $page.data.npub;
    let user: NDKUser;

    $: npub = $page.data.npub;

    onMount(() => {
        user = $ndk.getUser({npub});

        startUserView(user);
    });

    onDestroy(() => {
        userSubscription?.unref();
    })
</script>

{#if user}
    {#key user.pubkey}
        <slot />
    {/key}
{/if}