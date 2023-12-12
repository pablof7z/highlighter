<script lang="ts">
	import { Avatar, Name } from "@kind0/ui-common";
	import type { NDKUser } from "@nostr-dev-kit/ndk";
	import { ArrowLeft } from "phosphor-svelte";
    import { createEventDispatcher } from "svelte";
	import UserProfile from "./User/UserProfile.svelte";

    export let user: NDKUser;
    export let showBackArrow = false;

    const dispatch = createEventDispatcher();
</script>

<div class="justify-start items-center gap-3 inline-flex">
    {#if showBackArrow}
        <button class="btn btn-ghost btn-circle absolute left-4" on:click={() => dispatch("back")}>
            <ArrowLeft color="black" class="w-6 h-6" />
        </button>
    {/if}
    <UserProfile {user} let:userProfile let:fetching>
        <div class="w-10 h-10 relative">
            <div class="w-10 h-10 left-0 top-0 absolute bg-white rounded-full"></div>
            <Avatar {user} {userProfile} {fetching} class="w-10 h-10 left-0 top-0 absolute" />
            <div class="w-10 h-10 left-0 top-0 absolute rounded-full border-2 border-black"></div>
        </div>
        <div class="text-black text-lg font-medium">
            <Name {user} {userProfile} {fetching} />
        </div>
    </UserProfile>
</div>