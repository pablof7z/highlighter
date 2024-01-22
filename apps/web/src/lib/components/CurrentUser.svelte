<script lang="ts">
	import UserDrawer from './PageSidebar/UserDrawer.svelte';
	import { Avatar, bunkerNDK, ndk, pageDrawerToggle, user } from '@kind0/ui-common';
	import { loginState } from '$stores/session';
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

{#if $loginState}
    <div class="w-full" transition:fade>
        {#if $user}
            <UserProfile user={$user} let:userProfile let:fetching>
                <button on:click={clicked}>
                    <Avatar user={$user} {userProfile} {fetching} />
                </button>
            </UserProfile>
        {:else}
            <slot />
        {/if}
    </div>
{/if}