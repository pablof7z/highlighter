<script lang="ts">
	import { goto } from "$app/navigation";
	import { page } from "$app/stores";
	import UserProfile from "$components/User/UserProfile.svelte";
	import { getUserSupporters } from "$stores/user-view";
	import { Avatar } from "@kind0/ui-common";
	import type { Hexpubkey, NDKUser, NDKUserProfile } from "@nostr-dev-kit/ndk";
	import { onMount } from "svelte";
	import { closeModal } from "svelte-modals";
	import { Readable } from "svelte/store";

    export let user: NDKUser;
    let userProfile: NDKUserProfile;
    let authorUrl: string;

    function seeContentClicked() {
        closeModal();
        if ($page.url.pathname === authorUrl) {
            window.location.reload();
            return;
        } else {
            goto(authorUrl, { invalidateAll: true });
        }
    }
</script>

<UserProfile {user} bind:userProfile bind:authorUrl let:fetching>
    <div class="flex flex-col items-center gap-6 p-6">
        <Avatar {userProfile} {fetching} class="w-32 h-32" type="square" />
        <h1 class="text-white text-7xl font-black">Hooray!</h1>
        <h1 class="text-white text-2xl font-medium grow">Thank you for your support!</h1>

        <button on:click={seeContentClicked} class="button button-primary w-full place-self-end">
            Go backstage
        </button>
    </div>
</UserProfile>