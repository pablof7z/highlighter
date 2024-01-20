<script lang="ts">
    import UserDropdown from './UserDropdown.svelte';
	import { openModal } from 'svelte-modals';
	import SignupModal from '$modals/SignupModal.svelte';
	import { bunkerNDK, ndk, user } from '@kind0/ui-common';
	import { login } from '$utils/login';
	import { loginState } from '$stores/session';
	import { fade } from 'svelte/transition';
	import { User } from 'phosphor-svelte';
</script>

{#if $loginState}
    <div class="w-full" transition:fade>
        {#if $user}
            <UserDropdown />
        {:else}
            <slot />
        {/if}
    </div>
{/if}