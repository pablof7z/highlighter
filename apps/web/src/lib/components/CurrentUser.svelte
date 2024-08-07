<script lang="ts">
	import UserProfile from './User/UserProfile.svelte';
	import currentUser from '$stores/currentUser';
	import { UserCircle } from 'phosphor-svelte';
	import Avatar from './User/Avatar.svelte';
	import { openModal } from '$utils/modal';
	import SignupModal from '$modals/SignupModal.svelte';
	import { bunkerNDK, ndk } from '$stores/ndk';
	import { login } from '$utils/login';

    export let withName = false;

    async function openSignupModal() {
        if (window.nostr) {
            const u = await login(undefined);
            if (u) {
                $currentUser = u;
                return;
            }
        }

        openModal(SignupModal);
    }
</script>

<div class="{$$props.class??""}">
    {#if $currentUser}
        <UserProfile user={$currentUser} let:userProfile let:authorUrl let:fetching>
            <a href="/settings" class="flex-none" on:click={() => console.log('navigate again')}>
                <Avatar user={$currentUser} {userProfile} {fetching} class="w-[40px] h-[40px] object-cover flex-none {$$props.avatarClass??""}" />
            </a>
        </UserProfile>
    {:else}
        <a href="/signup" class="w-10 h-10">
            <UserCircle class="w-full h-full" weight="light" />
        </a>
    {/if}
</div>