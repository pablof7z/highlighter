<script lang="ts">
	import ContentCard from "./ContentCard.svelte";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;
    export let userProfile: NDKUserProfile | undefined = undefined;
    export let authorUrl: string;
</script>

{#if !userProfile}
    <UserProfile {user} bind:userProfile bind:authorUrl />
{/if}

{#if userProfile?.displayName}
    <ContentCard
        title={userProfile?.displayName}
        image={userProfile?.image}
        description={userProfile?.about}
        href={authorUrl}
        {...$$props}
        class="w-[var(--user-card-width)] h-[var(--user-card-height)]"
    />
{/if}