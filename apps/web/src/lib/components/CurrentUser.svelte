<script lang="ts">
	import UserDrawer from './PageSidebar/UserDrawer.svelte';
	import { Avatar, bunkerNDK, ndk, pageDrawerToggle, user } from '@kind0/ui-common';
	import { fade } from 'svelte/transition';
	import UserProfile from './User/UserProfile.svelte';
    import { rightSidebar } from '@kind0/ui-common';

    function clicked() {
        $pageDrawerToggle = true;
        rightSidebar.set({
            component: UserDrawer,
            props: {}
        });
    }
</script>

<div class="w-full flex-none" transition:fade>
    {#if $user}
        <UserProfile user={$user} let:userProfile let:authorUrl let:fetching>
            <button on:click={clicked} class="sm:hidden">
                <Avatar user={$user} {userProfile} {fetching} class="flex-none" />
            </button>

            <a href={authorUrl} class="max-sm:hidden">
                <Avatar user={$user} {userProfile} {fetching} class="flex-none" />
            </a>
        </UserProfile>
    {:else}
        <slot />
    {/if}
</div>