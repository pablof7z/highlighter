<script lang="ts">
	import UserDrawer from './PageSidebar/UserDrawer.svelte';
	import { Avatar, bunkerNDK, ndk, pageDrawerToggle } from '@kind0/ui-common';
	import { fade } from 'svelte/transition';
	import UserProfile from './User/UserProfile.svelte';
    import { rightSidebar } from '@kind0/ui-common';
	import currentUser from '$stores/currentUser';

    function clicked() {
        $pageDrawerToggle = true;
        rightSidebar.set({
            component: UserDrawer,
            props: {}
        });
    }
</script>

<div class="w-full flex-none" transition:fade>
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
        <slot />
    {/if}
</div>