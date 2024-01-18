<script lang="ts">
    import UserDropdown from './UserDropdown.svelte';
	import { openModal } from 'svelte-modals';
	import SignupModal from '$modals/SignupModal.svelte';
	import { bunkerNDK, ndk, user } from '@kind0/ui-common';
	import { login } from '$utils/login';
	import { loginState } from '$stores/session';
	import { fade } from 'svelte/transition';
	import { User } from 'phosphor-svelte';

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
            <button class="btn btn-ghost btn-circle" on:click={openSignupModal}>
                <User class="w-5 h-5" />
            </button>
        {/if}
    </div>
{/if}