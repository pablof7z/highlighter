<script lang="ts">
    import { page } from "$app/stores";
    import type { NDKUser } from "@nostr-dev-kit/ndk";
    import { onDestroy, onMount } from "svelte";
	import { startUserView, userSubscription } from "$stores/user-view";

    export let user: NDKUser = $page.data.user;

    let npub: string;

    // $: npub = $page.data.npub;

    try {
        if (user && user.npub) {
            npub = user.npub;
            startUserView(user);
        }
    } catch {}

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