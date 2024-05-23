<script lang="ts">
	import AvatarWithName from './User/AvatarWithName.svelte';
	import { Avatar, bunkerNDK, ndk } from '@kind0/ui-common';
	import { fade } from 'svelte/transition';
	import UserProfile from './User/UserProfile.svelte';
	import currentUser from '$stores/currentUser';
	import { UserCircle } from 'phosphor-svelte';
	import { login } from '$utils/login';
	import { openModal } from '$utils/modal';
    import SignupModal from '$modals/SignupModal.svelte';

    export let withName = false;

    async function openSignupModal() {
        // if (window.nostr) {
        //     const u = await login($ndk, $bunkerNDK, 'nip07');
        //     if (u) {
        //         $currentUser = u;
        //         return;
        //     }
        // }

        // openModal(SignupModal);
    }
</script>

<div class="w-full {$$props.class??""}" transition:fade>
    {#if $currentUser}
        <UserProfile user={$currentUser} let:userProfile let:authorUrl let:fetching>
            {#if !withName}
                <a href={authorUrl} class="max-sm:hidden">
                    <Avatar user={$currentUser} {userProfile} {fetching} class="flex-none {$$props.avatarClass??""}" />
                </a>
            {:else}
                <a href={authorUrl} class="max-sm:hidden">
                    <AvatarWithName user={$currentUser} {userProfile} {fetching} class="flex-none" avatarClass={$$props.avatarClass??""} />
                </a>
            {/if}
        </UserProfile>
    {:else}
        <button on:click={openSignupModal} class="w-10 h-10">
            <UserCircle class="w-full h-full" weight="light" />
        </button>
    {/if}
</div>