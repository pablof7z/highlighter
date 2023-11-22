<script lang="ts">
    import UserDropdown from './UserDropdown.svelte';
	import { openModal } from 'svelte-modals';
	import SignupModal from '$modals/SignupModal.svelte';
	import { bunkerNDK, ndk, user } from '@kind0/ui-common';
	import { login } from '$utils/login';

    async function openSignupModal() {
        if (window.nostr) {
            const u = await login($ndk, $bunkerNDK, 'nip07');
            if (u) {
                $user = u;
                return;
            }
        }

        openModal(SignupModal);
    }
</script>

{#if $user}
    <UserDropdown />
{:else}
    <button class="button" on:click={openSignupModal}>
        Sign up
    </button>
{/if}

<style lang="postcss">
    .menu {
        @apply absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-base-300 text-base-content py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none;
    }

    li {
        @apply block px-4 py-2 font-medium  hover:bg-base-200 hover:text-gray-800 text-sm;
    }

    li a:hover {
        @apply !bg-transparent;
    }
</style>
