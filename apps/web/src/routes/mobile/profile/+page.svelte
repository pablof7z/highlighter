<script lang="ts">
	import { page } from "$app/stores";
	import UserProfileHomePage from "$views/UserProfileHomePage.svelte";
	import { ndk } from "@kind0/ui-common";
	import { NDKUser } from "@nostr-dev-kit/ndk";

    let userId: string | null;
    let view: string;

    let user: NDKUser;

    $: {
        userId = $page.url.searchParams.get('userId');
        view = $page.url.searchParams.get('view') ?? "profile";
        if (userId) user = $ndk.getUser({npub: userId});
    }
</script>

{#if user}
    {#key userId}
        {#if view === "profile"}
            <UserProfileHomePage {user} />
        {:else}
        {/if}
    {/key}
{/if}