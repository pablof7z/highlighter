<script lang="ts">
    import UserDropdown from './UserDropdown.svelte';
	import { openModal } from 'svelte-modals';
	import SignupModal from '$modals/SignupModal.svelte';
	import { bunkerNDK, ndk, user } from '@kind0/ui-common';
	import { login } from '$utils/login';
	import { page } from '$app/stores';
	import { loginState } from '$stores/session';
	import { fade } from 'svelte/transition';

    const hostname = $page.url.hostname;

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

{#if $loginState}
    <div transition:fade>
        {#if $user}
            <UserDropdown />
        {:else}
            <button class="button" on:click={openSignupModal}>
                Sign up
            </button>
        {/if}
    </div>
{/if}