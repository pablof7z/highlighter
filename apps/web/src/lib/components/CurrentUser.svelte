<script lang="ts">
	import UserDrawer from './PageSidebar/UserDrawer.svelte';
	import { Avatar, bunkerNDK, ndk, pageDrawerToggle } from '@kind0/ui-common';
	import { fade } from 'svelte/transition';
	import UserProfile from './User/UserProfile.svelte';
    import { rightSidebar } from '@kind0/ui-common';
	import currentUser from '$stores/currentUser';
	import { UserCircle } from 'phosphor-svelte';
	import { login } from '$utils/login';
	import { openModal } from 'svelte-modals';
    import SignupModal from '$modals/SignupModal.svelte';

    function clicked() {
        $pageDrawerToggle = true;
        rightSidebar.set({
            component: UserDrawer,
            props: {}
        });
    }

    async function openSignupModal() {
        if (window.nostr) {
            const u = await login($ndk, $bunkerNDK, 'nip07');
            if (u) {
                $currentUser = u;
                return;
            }
        }

        openModal(SignupModal);
    }
</script>

<div class="w-full" transition:fade>
    {#if $currentUser}
        <UserProfile user={$currentUser} let:userProfile let:authorUrl let:fetching>
            <button on:click={clicked} class="sm:hidden">
                <Avatar user={$currentUser} {userProfile} {fetching} class="flex-none" />
            </button>

            <a href={authorUrl} class="max-sm:hidden">
                <Avatar user={$currentUser} {userProfile} {fetching} class="flex-none" />
            </a>
        </UserProfile>
    {:else}
        <button on:click={openSignupModal} class="w-full h-full">
            <UserCircle class="w-full h-full" />
        </button>
    {/if}
</div>