<script lang="ts">
    import { page } from "$app/stores";
    import type { NDKUser } from "@nostr-dev-kit/ndk";
    import { ndk } from "@kind0/ui-common";
    import { onDestroy, onMount } from "svelte";
	import { startUserView, userSubscription } from "$stores/user-view";

    export let user: NDKUser = $page.data.user;

    // $: npub = $page.data.npub;

    onMount(() => {
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