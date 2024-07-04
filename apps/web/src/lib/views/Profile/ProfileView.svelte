<script lang="ts">
	import UserProfile from "$components/User/UserProfile.svelte";
	import { pageHeader } from "$stores/layout";
	import { NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";

    export let user: NDKUser;

    let collapsed = false;

    let userProfile: NDKUserProfile;
    
    $pageHeader = null;
</script>

<UserProfile {user} bind:userProfile />

<div title={userProfile?.displayName} class="!h-fit">
    {#if userProfile?.banner}
        <img src={userProfile?.banner} class="w-full h-[35rem] object-cover object-top z-1 transition-all duration-300  {collapsed ? "opacity-20" : "opacity-40"}" alt={userProfile?.name}>
    {/if}
</div>

<slot />