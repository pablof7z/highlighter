<script lang="ts">
	import { page } from "$app/stores";
	import CreatorShell from "$components/Creator/CreatorShell.svelte";
	import UserProfileHomePage from "$views/UserProfileHomePage.svelte";
	import { ndk } from "$stores/ndk.js";
	import { NDKUser } from "@nostr-dev-kit/ndk";
	import ProfileView from "$views/Profile/ProfileView.svelte";

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
            {#key user.pubkey}
                <CreatorShell {user}>
                    <UserProfileHomePage {user} />
                </CreatorShell>
            {/key}
        {:else}
        {/if}
    {/key}
{/if}