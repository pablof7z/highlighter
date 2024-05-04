<script lang="ts">
	import AvatarWithName from './User/AvatarWithName.svelte';
	import UserDrawer from './PageSidebar/UserDrawer.svelte';
	import { Avatar, bunkerNDK, ndk, pageDrawerToggle } from '@kind0/ui-common';
	import { fade } from 'svelte/transition';
	import UserProfile from './User/UserProfile.svelte';
    import { rightSidebar } from '@kind0/ui-common';
	import currentUser from '$stores/currentUser';
	import { UserCircle } from 'phosphor-svelte';
	import { login } from '$utils/login';
	import { openModal } from '$utils/modal';
    import SignupModal from '$modals/SignupModal.svelte';

    export let withName = false;

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

<div class="w-full {$$props.class??""}" transition:fade>
    {#if $currentUser}
        <UserProfile user={$currentUser} let:userProfile let:authorUrl let:fetching>
            {#if !withName}
                <button on:click={clicked} class="sm:hidden">
                    <Avatar user={$currentUser} {userProfile} {fetching} class="flex-none {$$props.avatarClass??""}" />
                </button>

                <a href={authorUrl} class="max-sm:hidden">
                    <Avatar user={$currentUser} {userProfile} {fetching} class="flex-none {$$props.avatarClass??""}" />
                </a>
            {:else}
                <button on:click={clicked} class="sm:hidden">
                    <AvatarWithName user={$currentUser} {userProfile} {fetching} class="flex-none" avatarClass={$$props.avatarClass??""} />
                </button>

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