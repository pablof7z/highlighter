<script lang="ts">
	import UserProfile from './User/UserProfile.svelte';
	import currentUser from '$stores/currentUser';
	import { UserCircle } from 'phosphor-svelte';
	import Avatar from './User/Avatar.svelte';

    export let withName = false;
</script>

<div class="{$$props.class??""}">
    {#if $currentUser}
        <UserProfile user={$currentUser} let:userProfile let:authorUrl let:fetching>
            <a href={authorUrl} class="flex-none" on:click={() => console.log('navigate again')}>
                <Avatar user={$currentUser} {userProfile} {fetching} size="large" class="object-cover flex-none {$$props.avatarClass??""}" />
            </a>
        </UserProfile>
    {:else}
        <a href="/signup" class="w-10 h-10">
            <UserCircle class="w-full h-full" weight="light" />
        </a>
    {/if}
</div>