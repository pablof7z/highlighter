<script lang="ts">
    import { page } from "$app/stores";
    import type { NDKUser } from "@nostr-dev-kit/ndk";
    import { onDestroy, onMount } from "svelte";
	import { startUserView, userSubscription } from "$stores/user-view";

    export let user: NDKUser = $page.data.user;

    // $: npub = $page.data.npub;

    onMount(() => {
        try {
            startUserView(user);
        } catch(e) {
            console.trace(e);
            alert(e);
        }
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