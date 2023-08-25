<script lang="ts">
    import ndk from '$lib/stores/ndk';
    import { login } from '$lib/utils/login';
    import { currentUser } from '$stores/current-user';
    import SubtleButton from '$lib/components/buttons/SubtleButton.svelte';
    import { browser } from '$app/environment';

    let noNip07extenion: boolean;

    $: noNip07extenion = browser ? !window.nostr : false;

    async function loginNip07() {
        const user = await login($ndk, undefined, 'nip07');

        if (!user) {
            alert('Login failed');
        } else {
            $currentUser = user;
            localStorage.setItem('nostr-key-method', 'nip07');
            localStorage.setItem('nostr-target-npub', $currentUser.npub);
        }
    }
</script>

{#if noNip07extenion}
    <div class="alert flex flex-col bg-base-300">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" class="stroke-info shrink-0 w-6 h-6"
            ><path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            /></svg
        >
        <span>No Nostr extension in your browser</span>
        <div class="hidden">
            <button class="btn btn-xs">Need help?</button>
        </div>
    </div>
{:else}
    <SubtleButton handleClick={loginNip07} class="w-full">
        <span slot="btn-content">Use Browser Extension</span>
    </SubtleButton>
{/if}
